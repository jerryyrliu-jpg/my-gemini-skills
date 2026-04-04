---
name: obsidian-canvas-creator
description: Generates structured Obsidian Canvas files (.canvas) and mind maps from text content to visualize information spatially. Use when the user asks for mind maps, visual diagrams, or spatial layouts in Obsidian.
---

# Obsidian Canvas Creator

This skill enables the generation of valid JSON Canvas files (`.canvas`) for Obsidian with advanced layout logic and intelligent node sizing.

## Core Principles

- **Spatial Layout**: Transform linear information into spatial diagrams.
- **Intelligent Sizing**: Node width and height must scale with content length (roughly 1.5-2px per character, min 250px width).
- **Z-Index**: Order nodes by importance or hierarchy in the array (last is top).

## Node Types & Attributes

| Type | Attributes | Description |
|---|---|---|
| `text` | `text` (Markdown) | Standard text cards. Use `\n` for line breaks. |
| `file` | `file` (path), `subpath` | Reference internal notes or attachments. |
| `link` | `url` | External web links. |
| `group` | `label`, `background` | Containers for organizing nodes. |

## Layout Algorithms

### 1. Mind Map (Hierarchical)
- **Central Node**: Place at `(0, 0)`.
- **Level 1**: Radial distribution around center (approx. 500px distance).
- **Level 2+**: Extend outward in branches to prevent overlap.
- **Spacing**: Maintain at least 100px gap between nodes.

### 2. Grid/Board (Categorical)
- **Columns**: Use `group` nodes as vertical swimlanes.
- **Alignment**: Align nodes to a 20px grid for clean visualization.

## Color Coding System

Assign colors based on depth or category for better visual parsing:
- **Red ("1")**: Root/Central concept.
- **Orange ("2") / Yellow ("3")**: Primary branches/categories.
- **Green ("4")**: Details/Tasks.
- **Cyan ("5") / Purple ("6")**: References/Supporting info.

## Edge Logic
- **Arrows**: Always use `"toEnd": "arrow"` for directional flow.
- **Labels**: Use short labels (1-3 words) to describe relationships.

## Example JSON Structure

```json
{
  "nodes": [
    {
      "id": "root-001",
      "type": "text",
      "x": 0,
      "y": 0,
      "width": 300,
      "height": 100,
      "color": "1",
      "text": "# Main Goal\nStrategy for 2026"
    }
  ],
  "edges": []
}
```

## Validation Checklist
1. All `id`s must be unique 16-char hex strings.
2. `fromNode` and `toNode` must exist.
3. No literal `\\n` in JSON strings (use `\n`).
4. Ensure no node overlaps using at least 50px buffer.
