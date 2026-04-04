---
name: beautiful-mermaid
description: "產出極具美感的 Mermaid 圖表（Block Diagram, Sequence, Flowchart），針對 Obsidian 渲染進行優化。"
---

# Skill: Beautiful Mermaid
**Author:** Gemini CLI (Integrated)
**Version:** 1.0.0
**Description:** 產出極具美感的 Mermaid 圖表（Block Diagram, Sequence, Flowchart），針對 Obsidian 渲染進行優化。

## 核心規範
當生成 Mermaid 圖表時，請遵循以下優化規則：

1. **色彩與風格 (Styling)**:
   - 使用 `subgraph` 來對功能模組進行視覺化分組。
   - 使用自定義 `classDef` 來定義節點顏色（如：藍色代表用戶、綠色代表資料庫、紅色代表警報）。
   - 加入背景色與圓角 (Round corners)。

2. **區塊圖優化 (Block Diagram)**:
   - 使用 `graph TD` 或 `graph LR` 時，確保層次清晰。
   - 在節點中使用圖示符號（如果支持）或更精確的標籤。

3. **樣式模板 (Template)**:
   ```mermaid
   graph TD
     classDef user fill:#f9f,stroke:#333,stroke-width:4px;
     classDef db fill:#69f,stroke:#333,stroke-width:2px;
     
     User[User Interface]:::user --> API[Backend API]
     API --> DB[(Database)]:::db
   ```
