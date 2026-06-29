#!/usr/bin/env bash
# =============================================================================
# cleanup_git.sh – Purge sensitive files from Stalvi git history
# =============================================================================
# PURPOSE
#   This script removes any secrets (keystores, .env files, key.properties)
#   that were ever accidentally committed to the repository history using
#   git-filter-repo (the git-project-endorsed replacement for BFG / filter-branch).
#
# WHEN TO RUN
#   Run ONLY if `git log --all --name-only` reveals sensitive files in past
#   commits. As of the last audit (2026-06-29) NO such files were found in
#   history, so this script is a safety net for future incidents.
#
# PRE-REQUISITES
#   1. Install git-filter-repo:
#        pip install git-filter-repo
#        (or: brew install git-filter-repo  /  sudo apt install git-filter-repo)
#   2. Create a FULL BACKUP of the repository before running.
#   3. All collaborators must re-clone after this script runs (history is rewritten).
#
# USAGE
#   chmod +x cleanup_git.sh
#   ./cleanup_git.sh
#
# AFTER RUNNING
#   git push --force-with-lease --all
#   git push --force-with-lease --tags
#   → Notify all collaborators to delete their local clones and re-clone.
#   → Rotate any credentials that were ever committed immediately.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# 0. Safety checks
# ---------------------------------------------------------------------------
if ! command -v git-filter-repo &>/dev/null; then
    echo "❌  git-filter-repo not found. Install it first:"
    echo "       pip install git-filter-repo"
    exit 1
fi

# Refuse to run on a dirty working tree.
if ! git diff --quiet HEAD 2>/dev/null; then
    echo "❌  Working tree has uncommitted changes. Commit or stash them first."
    exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

echo "🔍  Auditing git history for sensitive files..."

# ---------------------------------------------------------------------------
# 1. Detect whether any sensitive files exist in history
# ---------------------------------------------------------------------------
SENSITIVE_PATTERNS=(
    "*.jks"
    "*.keystore"
    "*.p12"
    "*.pem"
    ".env"
    ".env.*"
    "*.env"
    "key.properties"
    "android/key.properties"
    "android/app/key.properties"
    "android/local.properties"
    "local.properties"
    "google-services.json"
    "GoogleService-Info.plist"
)

FOUND_FILES=()
for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    # git log with pathspec to check if any commit ever touched this path.
    matches=$(git log --all --name-only --pretty=format:"" -- "$pattern" 2>/dev/null | sort -u | grep -v '^$' || true)
    if [[ -n "$matches" ]]; then
        while IFS= read -r f; do
            FOUND_FILES+=("$f")
        done <<< "$matches"
    fi
done

if [[ ${#FOUND_FILES[@]} -eq 0 ]]; then
    echo "✅  No sensitive files found in git history. Nothing to purge."
    exit 0
fi

echo ""
echo "⚠️   The following sensitive files were found in git history:"
for f in "${FOUND_FILES[@]}"; do
    echo "    • $f"
done
echo ""
echo "🔐  IMPORTANT: Rotate any credentials contained in the above files"
echo "    IMMEDIATELY – treat them as compromised."
echo ""

# ---------------------------------------------------------------------------
# 2. Prompt for confirmation
# ---------------------------------------------------------------------------
read -r -p "Do you want to purge these files from ALL git history? [y/N] " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted. No changes made."
    exit 0
fi

# ---------------------------------------------------------------------------
# 3. Build the --path-glob arguments for git-filter-repo
# ---------------------------------------------------------------------------
FILTER_ARGS=()
for f in "${FOUND_FILES[@]}"; do
    FILTER_ARGS+=("--path" "$f")
done

echo ""
echo "🧹  Running git-filter-repo to remove sensitive files from history..."
# --invert-paths keeps everything EXCEPT the listed paths (i.e., removes them).
# --force is required because we are operating on the current checkout.
git filter-repo --invert-paths "${FILTER_ARGS[@]}" --force

echo ""
echo "✅  History rewrite complete."
echo ""
echo "📋  NEXT STEPS (mandatory):"
echo "    1. Review the rewritten history:  git log --oneline --name-status"
echo "    2. Force-push all branches:       git push --force-with-lease --all"
echo "    3. Force-push all tags:            git push --force-with-lease --tags"
echo "    4. Notify ALL collaborators to:   rm -rf <repo> && git clone <url>"
echo "    5. Rotate compromised credentials immediately."
echo ""
echo "⚠️   If this repository was ever public or shared, assume the credentials"
echo "    are compromised regardless of the history purge."
