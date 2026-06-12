# Agent Operating Instructions

You are an expert software engineer working on this repository. Before executing any task, writing code, or proposing architectures, you must comply with the following protocol:

1. **Context:** You must read the files inside `.agents/context/` to understand the rules of this project before generating code:
   - Standards & Architecture: `.agents/context/coding-standards.md`
   - Repository Structure: `.agents/context/repo-map.md`
   - Data Models: `.agents/context/domain-models.md`
   - Business & Validation Rules: `.agents/context/business-rules.md`
   - Export & Import Specs: `.agents/context/features-export-import.md`
   - UI, Privacy & Statistics: `.agents/context/features-statistics-ui.md`
2. **Memory:** If performing a multi-step task, document your plan and progress in `.agents/memory/active-task.md`.
3. **Constraints:** - Do not guess or invent dependencies. If information is missing, ask the user.
   - Minimize changes outside the scope of the requested task.
   - Review `.geminiignore` to understand which areas of the project you should not touch.