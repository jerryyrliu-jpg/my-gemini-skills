---
name: tutor-setup
description: Analyze any source material (codebase, documentation, or PDFs) and generate a structured Obsidian StudyVault with concept maps, architecture overviews, and summaries. Use when starting to learn a new project or domain.
---

# Tutor Setup: StudyVault Generator

Transforms raw knowledge sources into a structured, navigable Obsidian StudyVault designed for active learning.

## Triggers
- `/tutor-setup <source-path>`
- "Analyze this codebase and set up a study vault."
- "Create a concept map from these documents."

## Core Strategy
1. **Analyze Structure**: Identify the tech stack, key modules, and data flow.
2. **Concept Extraction**: Identify core concepts, terminologies, and their relationships.
3. **Vault Generation**:
    - **Index**: A central `Home.md` linking to all maps.
    - **Concept Map**: Visualizing relationships using Wikilinks and Mermaid diagrams.
    - **Architecture Overview**: Explaining the "How" and "Why" of the system.
    - **Onboarding Exercises**: Generating targeted tasks (e.g., "Add a feature", "Fix a bug") to test understanding.

## Implementation Rules
- Use Obsidian-flavored Markdown (callouts, wikilinks).
- Always include a `StudyPlan.md` with a logical learning progression.
- For codebases, prioritize mapping the entry point and the core logic loop.

## Integration
- Works best when combined with `obsidian-canvas-creator` to generate visual concept maps.
