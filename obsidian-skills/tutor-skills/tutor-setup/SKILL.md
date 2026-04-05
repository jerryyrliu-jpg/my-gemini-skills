---
name: tutor-setup
description: Analyze any source material (codebase, documentation, or PDFs) and generate a structured Obsidian StudyVault with concept maps, architecture overviews, and summaries. Use when starting to learn a new project or domain.
---

# Tutor Setup: StudyVault Generator

Transforms raw knowledge sources into a structured, navigable Obsidian StudyVault.

## Triggers
- `/tutor-setup <source-path>`
- "Analyze this codebase and set up a study vault."

## Phased Workflow
1. **D1: Source Discovery**: Scan files, identify file types.
2. **D2: Stack Detection (Codebase Mode)**: Refer to `references/codebase-logic.md`. Identify languages, frameworks, and entry points.
3. **D3: Content Extraction**: Parse text and code to identify core concepts.
4. **D4: Dependency Mapping**: Map how concepts/modules relate.
5. **D5: Dashboard Creation**: Generate `Dashboard.md` using `references/dashboard-template.md`.
6. **D6: Concept Note Generation**: Create notes using `references/concept-note-format.md`.
7. **D7: Active Recall Integration**: Add folded answers to questions.
8. **D8: Wiki-linking**: Link all notes.
9. **D9: Quality Checklist**: Verify all links and structure.

## Requirements
- Use Obsidian callouts (`> [!info]`) and Mermaid diagrams.
- Always include a `StudyPlan.md`.
