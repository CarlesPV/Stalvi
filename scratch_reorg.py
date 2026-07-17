import json
import re

groups = {
    "Auth": ["auth", "pin", "changePin"],
    "Settings": ["settings", "themeMode", "profileSettings", "language", "export", "import", "deleteAllData", "recycleBin", "aboutMe", "pdf", "btnExport", "btnRestore"],
    "Dashboard": ["overview", "accounts", "recentTransactions", "noTransactions", "balanceTotal"],
    "Transactions": ["transaction", "income", "expense", "btnSaveTransaction", "createAccount", "filter", "label", "category", "tag", "autoTx", "fallback", "account", "transfer"],
    "Budgets": ["budget", "savings", "target", "startDate", "endDate", "goalName"],
    "Statistics": ["statistics", "preset", "chart_scale", "expense_vs_income"],
    "Errors": ["error", "failed", "splashStartupFailed", "splashSecureStorageError", "unexpectedError", "incorrectOldPin", "pinsDoNotMatch"],
    "General": ["appTitle", "splashTagline", "tryAgain", "getStarted", "btn", "warning", "replaceDefaultAccountConfirm", "unknownAccount", "noDataAvailable", "termsAndConditions", "privacyPolicy", "acrossAccountsCount", "defaultAccountName", "setAsDefault", "optionalPlaceholder"]
}

def get_group(key):
    if key.startswith("@@"):
        return "Metadata"
    key_lower = key.lower()
    # Try to match the prefixes
    if "error" in key_lower or "failed" in key_lower or "incorrect" in key_lower or "mismatch" in key_lower:
        return "Errors"
    if "auth" in key_lower or "pin" in key_lower:
        return "Auth"
    if "budget" in key_lower or "savings" in key_lower or "goal" in key_lower:
        return "Budgets_and_Goals"
    if "statistic" in key_lower or "preset" in key_lower or "chart" in key_lower:
        return "Statistics"
    if "setting" in key_lower or "export" in key_lower or "import" in key_lower or "theme" in key_lower or "language" in key_lower or "pdf" in key_lower or "recycle" in key_lower or "about" in key_lower:
        return "Settings"
    if "transaction" in key_lower or "income" in key_lower or "expense" in key_lower or "account" in key_lower or "filter" in key_lower or "category" in key_lower or "tag" in key_lower or "transfer" in key_lower or "autotx" in key_lower:
        return "Transactions"
    if "overview" in key_lower or "balance" in key_lower:
        return "Dashboard"
    
    return "General"

def process_file(filepath, base_keys_order):
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
        
    # Group the base keys
    if base_keys_order is None:
        grouped_keys = {
            "Metadata": [],
            "General": [],
            "Auth": [],
            "Dashboard": [],
            "Transactions": [],
            "Budgets_and_Goals": [],
            "Statistics": [],
            "Settings": [],
            "Errors": []
        }
        
        # Determine base keys and their @ counterparts
        base_keys = []
        for k in data.keys():
            if k.startswith("@@"):
                grouped_keys["Metadata"].append(k)
            elif not k.startswith("@"):
                base_keys.append(k)
                
        for k in base_keys:
            g = get_group(k)
            grouped_keys[g].append(k)
            
        for g in grouped_keys:
            if g != "Metadata":
                grouped_keys[g].sort()
                
        # Create base_keys_order
        base_keys_order = []
        for g in grouped_keys:
            if grouped_keys[g]:
                base_keys_order.append((g, grouped_keys[g]))
    
    # Generate the output text
    output_lines = ["{"]
    
    # Process metadata first
    metadata_keys = [k for k in data.keys() if k.startswith("@@")]
    for k in metadata_keys:
        val = json.dumps(data[k], ensure_ascii=False)
        output_lines.append(f'  "{k}": {val},')
        
    for g, keys in base_keys_order:
        if g == "Metadata" or not keys:
            continue
        output_lines.append("")
        for k in keys:
            if k in data:
                val = json.dumps(data[k], ensure_ascii=False)
                output_lines.append(f'  "{k}": {val},')
            if f"@{k}" in data:
                val = json.dumps(data[f"@{k}"], ensure_ascii=False)
                # Ensure we handle multiline dict properly for @ keys
                # json.dumps doesn't format nicely, but we can do it
                val = json.dumps(data[f"@{k}"], ensure_ascii=False, indent=4).replace('\n', '\n  ')
                output_lines.append(f'  "@{k}": {val},')
                
    # Remove last comma
    if output_lines[-1].endswith(","):
        output_lines[-1] = output_lines[-1][:-1]
        
    output_lines.append("}")
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write('\n'.join(output_lines) + '\n')
        
    return base_keys_order

base_order = process_file("/home/carlesp/Proyectos/Stalvi/lib/core/l10n/app_en.arb", None)
process_file("/home/carlesp/Proyectos/Stalvi/lib/core/l10n/app_es.arb", base_order)
process_file("/home/carlesp/Proyectos/Stalvi/lib/core/l10n/app_ca.arb", base_order)
