---
name: beautiful-mermaid
description: Create beautiful, highly aesthetic Mermaid diagrams (flowcharts, sequence, state, class, ER, XY charts, C4 architecture) with proper syntax, theming, and ASCII output. Use when generating or editing any Mermaid diagram. Do NOT trigger when the user request solely targets outputting standard Markdown tables, plain text directory trees, or non-Mermaid diagram engines (e.g., PlantUML, Graphviz DOT, D2, Excalidraw).
---

# Beautiful Mermaid Diagrams
**Version:** 2.2.0 (Hybrid Fusion Masterpiece)
**Description:** Generate highly aesthetic Mermaid diagrams optimized for Obsidian rendering, professional documentation, and programmatic generation.

## 🎨 Core Design Aesthetics (Zero-Dependency)

When generating Markdown Mermaid diagrams, follow these rules to deliver a premium visual experience comparable to Figma or Excalidraw:

1. **Global Initialization Directive (`%%{init}%%`)**:
   - Always include the `%%{init: { ... }}%%` block at the very top of your diagram to configure global fonts, lines, and base colors.
   - Recommended Fonts: `Inter`, `Outfit`, `PingFang TC`, `Segoe UI`, `system-ui`.
   - To maintain theme adaptability in Dark and Light modes, omit `background` for transparent rendering. Always explicitly inject `"edgeLabelBackground": "transparent"` into `themeVariables` to prevent dark mode contrast glare.

2. **Curated Color Palettes (WCAG >= 4.5:1 Compliant)**:
   - **Tokyo Night**: Deep cybernetic hierarchy.
     - Primary Node: `#3d59a1` / Text `#ffffff`
     - Database: `#2e7d32` / Text `#ffffff`
     - Decision/Logic: `#7b1fa2` / Text `#ffffff`
     - Warning/Error: `#c62828` / Text `#ffffff`
     - Notes/Comments: `#f57c00` (Orange) / Text `#1f2335` (Dark blue-black, contrast 7.15:1)
     - Stroke/Border: `#1f2335` (Thin 1px~2px rounded borders)
   - **Catppuccin**: Soft pastel hierarchy. Lavender `#b4befe`, Mauve `#cba6f7`, Peach `#fab387`.
   - **Nord**: Minimalist cold-grey hierarchy. Frost Blue `#88c0d0`, Green `#a3be8c`, Purple `#b48ead`.

## 🛡️ Syntax Safety & Compatibility Iron Rules (Obsidian & CLI)

To prevent Jison parser crashes and `Unsupported markdown` rendering failures:
1. **Bidirectional Decoupling (No `<-->`)**: Never use `<-->`. Do not downgrade to undirected lines `---` (which destroys architecture semantics). Explicitly decompose into dual unidirectional edges: `A -->|req| B` and `B -->|resp| A`.
2. **Official Subgraph Syntax**: Never write `subgraph "Title"` (Jison interprets quoted text as ID and crashes). Always enforce official syntax: `subgraph ID ["Label Text"]`.
3. **Ordered List Trap (Obsidian Bug)**: Never start link or node labels with numbers followed by periods (e.g., `-->|1. Fetch|` or `Node["1. Fetch"]`), which triggers an HTML `<ol>` list parsing crash. If sequencing is mandatory, escape `1\. Fetch` or use full-width numerals.
4. **Reserved Bracket Trap**: Never use square brackets inside link labels (e.g., `-->|[1] Fetch|`). Use alphanumeric text or modern quoted syntax: `A -- "[1] Fetch" --> B`.
5. **Internal Quote Entity Rule**: Never use backslash escapes `\"` inside double-quoted node labels. Strictly replace quotes with HTML entities `&quot;` (e.g., `A["Payload: &quot;user_id&quot;"]`).
6. **Asymmetric Flag Quote Prohibition**: Asymmetric flag nodes (`id>label]`) **strictly forbid double quotes** around their labels (e.g., write `E>Step 1]`, never `E>"Step 1"]`).
7. **Obsidian Callout Indentation Rule**: When embedding Mermaid inside Obsidian Callouts (e.g., `> [!NOTE] Architecture`), **every single line** of the Mermaid block must be prefixed with `> `.
8. **Entity Naming & Ampersands**: Node IDs must contain alphanumeric characters and underscores only (no hyphens `-` or dots `.`). Ampersands inside labels must be written as HTML entities `&amp;`.

## 🏢 C4 Architecture Diagrams (Flowchart-Simulated)

*Architecture Tradeoff Note*: Official native `C4Context` diagrams in Mermaid suffer from over-wide box models and rigid theming in Obsidian. For markdown documentation, use **Flowchart-Simulated C4** layouts.

```mermaid
%%{init: {
  "theme": "base",
  "themeVariables": {
    "fontFamily": "Inter, system-ui, sans-serif",
    "lineColor": "#707070",
    "edgeLabelBackground": "transparent"
  }
}}%%
flowchart TB
  classDef c4Person fill:#08427b,stroke:#073b6e,stroke-width:1px,color:#ffffff;
  classDef c4Internal fill:#1168bd,stroke:#0f5ca6,stroke-width:1px,color:#ffffff;
  classDef c4External fill:#616161,stroke:#424242,stroke-width:1px,color:#ffffff;

  User(["User<br/>'[Person]'"]):::c4Person
  subgraph sys_boundary ["System Boundary: E-Commerce Platform"]
    WebApp["Web Application<br/>'[Container: React]'"]:::c4Internal
    DB[("Database<br/>'[Container: PostgreSQL]'")]:::c4Internal
  end
  style sys_boundary fill:none,stroke:#999999,stroke-width:2px,stroke-dasharray:5;

  User -->|Browses catalog &amp; orders (HTTPS)| WebApp
  WebApp -->|Queries &amp; updates (SQL)| DB
```

## 📐 Supported Diagram Cheatsheet

### 1. Flowcharts
Node shapes (always include instance ID): `A[text]` rectangle, `B{text}` diamond, `C([text])` stadium, `D((text))` circle, `E>text]` asymmetric flag (no quotes allowed), `F[[text]]` subroutine.

### 2. ER Diagrams (`erDiagram`)
Syntax: `EntityA <LeftCardinality><Line><RightCardinality> EntityB : "Role Label"`
- *Directional Symmetry Rule*: Left connectors (`|o`, `}o`, `}|`, `||`) must mirror horizontally when used on right connectors (`o|`, `o{`, `|{`, `||`).
- Lines: `--` identifying (solid), `..` non-identifying (dashed).
- Cardinalities: `||` exactly one, `o|` / `|o` zero or one, `}|` / `|{` one or more, `}o` / `o{` zero or more.
- Example: `CUSTOMER ||--o{ ORDER : "places"`

### 3. XY Charts (`xychart-beta`)
Orientation declaration at block header (vertical is default and can be omitted): `xychart-beta` or `xychart-beta horizontal`
Supports `title "..."`, `x-axis [...]`, `y-axis "..." min --> max`, `bar [...]`, `line [...]`.

### 4. Sequence & Class Diagrams
Sequence: `->>` solid arrowhead, `-->>` dotted arrowhead. Class: `<|--` inheritance, `*--` composition, `o--` aggregation.

## 💻 Programmatic & ASCII Generation (`beautiful-mermaid` library)

When writing server-side Node.js/Bun scripts or CLI tools:
```typescript
import { renderMermaidSVG, renderMermaidASCII, THEMES } from 'beautiful-mermaid'

// SVG Rendering
const svg = renderMermaidSVG(diagram, THEMES['tokyo-night']) // or { bg: '#1a1b26', fg: '#a9b1d6' }

// ASCII Terminal Rendering (Default mode outputs crisp Unicode box-drawing art ┌───┐)
const unicodeArt = renderMermaidASCII(`graph LR; A --> B --> C`)

// Legacy ASCII Mode (Outputs pure 7-bit ASCII +---+ only for restricted environments)
const legacyAscii = renderMermaidASCII(`graph LR; A --> B --> C`, { useAscii: true })
```
Built-in library themes (15): `zinc-light`, `zinc-dark`, `tokyo-night`, `tokyo-night-storm`, `tokyo-night-light`, `catppuccin-mocha`, `catppuccin-latte`, `nord`, `nord-light`, `dracula`, `github-light`, `github-dark`, `solarized-light`, `solarized-dark`, `one-dark`.

## References
- [Mermaid.js Documentation](https://mermaid.js.org/)
- [beautiful-mermaid GitHub](https://github.com/lukilabs/beautiful-mermaid)

#2026-06-22
