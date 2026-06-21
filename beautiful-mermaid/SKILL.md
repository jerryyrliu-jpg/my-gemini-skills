---
name: beautiful-mermaid
description: "Generate highly aesthetic Mermaid diagrams (Block, Sequence, Flowchart, C4 Context/Container/Component) optimized for Obsidian and high-end documentation."
---

# Skill: Beautiful Mermaid
**Author:** Gemini CLI (Integrated)
**Version:** 1.3.0
**Description:** Generate highly aesthetic Mermaid diagrams optimized for Obsidian rendering and professional documentation.

## 🎨 Core Design Aesthetics
When generating Mermaid diagrams, follow these optimization rules to deliver a premium, professional-grade visual experience comparable to Figma or Excalidraw:

1. **Global Initialization Directive (Mermaid Init Directive)**:
   - Always include the `%%{init: { ... }}%%` block at the very top of your diagram to configure global fonts, lines, and base colors.
   - Recommended Fonts: `Inter`, `Outfit`, `PingFang TC`, `Segoe UI`, `system-ui`.
   - To prevent flash of unstyled content and maintain theme adaptability (supporting both Dark and Light modes), prefer desaturated base themes or leave the `background` parameter adaptable (omit `background` for transparent rendering).

2. **Curated Color Palettes**:
   - **Tokyo Night (Default / Recommended)**: Deep, cybernetic blue/purple tone.
     - Primary Node: `#7aa2f7` (Blue) / Text `#ffffff`
     - Database: `#9ece6a` (Green) / Text `#1a1b26`
     - Decision/Condition: `#bb9af7` (Purple) / Text `#ffffff`
     - Warning/Error: `#f7768e` (Red) / Text `#ffffff`
     - Notes/Comments: `#e0af68` (Yellow) / Text `#1a1b26`
     - Stroke/Border: `#24283b` or `#1f2335`
   - **Catppuccin**: Soft, pastel tones.
     - Lavender: `#b4befe`, Green: `#a6e3a1`, Mauve: `#cba6f7`, Red: `#f38ba8`, Peach: `#fab387`
   - **Nord**: Minimalist, Nordic cold-grey tone.
     - Frost Blue: `#88c0d0`, Green: `#a3be8c`, Purple: `#b48ead`, Red: `#bf616a`, Yellow: `#ebcb8b`

3. **Node Styles & Hierarchy (Shapes)**:
   - Differentiate layers using distinct geometric shapes:
     - Start / End / Entrance: Rounded rectangle `Node([Text])` or capsule.
     - Process / Action: Standard rectangle `Node[Text]`.
     - Decision / Logic: Diamond shape `Node{Text}`.
     - Database / Storage: Cylindrical database shape `Node[(Text)]`.
     - Subsystems / Containers: Structured `subgraph` blocks.
   - Keep node borders thin (1px ~ 2px recommended) and use rounded corners.

---

## 🚀 Advanced Layouts & Styling (mermaid-expert)

### 1. Custom themeVariables
Use custom `themeVariables` in the init block to override specific element details (e.g., actor boxes, loop boundaries, edge labels) to prevent default high-contrast jarring colors:
```text
%%{init: {
  "theme": "base",
  "themeVariables": {
    "fontFamily": "Inter, system-ui, sans-serif",
    "primaryColor": "#24283b",
    "primaryTextColor": "#c0caf5",
    "lineColor": "#565f89",
    "edgeLabelBackground": "#1a1b26"
  }
}}%%
```

### 2. Styling Nodes with Class Definitions
- Define reusable node classes via `classDef` at the top or bottom of the diagram.
- Use explicit class syntax `NodeID:::ClassName` to apply styles.
- **Tip**: To achieve styling equivalent to multiple class definitions, define composite classes (e.g., `classDef activeWarning fill:#f7768e,stroke:#db4b4b,stroke-width:2px,stroke-dasharray:5;`).

### 3. Text Wrapping & Link Formatting
- **Text Wrapping**: Mermaid does not auto-wrap text inside shapes by default. Use quotes and HTML break tags `<br/>` to format multi-line labels: `NodeID["**Title**<br/>Description line 1<br/>Description line 2"]`.
- **Link Formatting**: Avoid raw characters that interfere with Mermaid parser syntax. For links, use standard markdown format inside nodes, or use Mermaid's built-in click/callback functionality if interactive.
- **Label Escape**: Wrap label text in double quotes if it contains parentheses, brackets, or braces (e.g., `Node["System (Internal)"]`).

---

## 🏢 C4 Architecture & Component Diagrams
Design C4 Model Diagrams (System Context, Container, Component) natively in Mermaid using clean custom style variables and C4 structural conventions.

### C4 Diagram Design Rules:
1. **Color Conventions**:
   - **Person / User**: Dark Blue (`#08427b`)
   - **Internal System / Container / Component**: Medium Blue (`#1168bd`)
   - **External System / Person**: Grey (`#999999`)
   - **Database**: Blue Cylindrical Node with DB label formatting.
2. **Clear Boundaries**:
   - Use `subgraph` for System Boundaries, Enterprise Boundaries, and Container Boundaries.
   - Style boundaries with dashed borders (`stroke-dasharray: 5 5`) and transparent backgrounds to distinguish them clearly from system components.
3. **Relationships**:
   - Always label relationship links clearly with the action and technology protocol.
   - Format: `Source -->|Action Description (Protocol)| Target` or `Source -- "Action Description (Protocol)" --> Target`.

### Native C4 Context & Container Template:
```mermaid
%%{init: {
  "theme": "base",
  "themeVariables": {
    "fontFamily": "Inter, system-ui, sans-serif",
    "background": "#f8f9fa",
    "lineColor": "#707070",
    "edgeLabelBackground": "#ffffff"
  }
}}%%
graph TB
  %% Class Definitions
  classDef c4Person fill:#08427b,stroke:#073b6e,stroke-width:1px,color:#ffffff;
  classDef c4Internal fill:#1168bd,stroke:#0f5ca6,stroke-width:1px,color:#ffffff;
  classDef c4External fill:#999999,stroke:#888888,stroke-width:1px,color:#ffffff;
  classDef c4Boundary fill:none,stroke:#cccccc,stroke-width:2px,stroke-dasharray:5 5,color:#333333;

  %% Person Node
  User(["User<br/>'[Person]'"]):::c4Person

  %% System Boundary
  subgraph System_Boundary ["System Boundary: E-Commerce Platform"]
    Web_App["Web Application<br/>'[Container: React]'<br/><br/>Allows users to browse catalog and purchase items."]:::c4Internal
    API_Gateway["API Gateway<br/>'[Container: NestJS]'<br/><br/>Routes traffic and handles authentication."]:::c4Internal
    DB[("Database<br/>'[Container: PostgreSQL]'<br/><br/>Stores catalog, order data, and user accounts.")]:::c4Internal
  end
  style System_Boundary fill:none,stroke:#999999,stroke-width:2px,stroke-dasharray:5 5;

  %% External System
  Payment_Gateway["Payment Gateway<br/>'[System: Stripe]'<br/><br/>Processes credit card transactions."]:::c4External

  %% Relationships
  User -->|Browses catalog & orders (HTTPS)| Web_App
  Web_App -->|API Requests (HTTPS/JSON)| API_Gateway
  API_Gateway -->|Queries & updates (SQL)| DB
  API_Gateway -->|Sends transactions (HTTPS/REST)| Payment_Gateway
```

---

## 💡 Obsidian Optimization Tips
1. **Theme Adaptability**: When defining custom colors, prioritize color schemes that remain legible and comfortable to look at in both light and dark themes (such as desaturated Tokyo Night tones). If you want background to adapt to light mode automatically, recommend omitting the `"background"` parameter.
2. **Syntax Compatibility**: Avoid raw HTML tags or unescaped special characters inside node labels to prevent rendering parsing issues in Obsidian. If labels contain parentheses or brackets, wrap the label text in double quotes (e.g., `Node["Label (Info)"]`).
