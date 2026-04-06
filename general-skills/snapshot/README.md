# Snapshot (Session 記憶快照)

這是一個工業級的 Session 狀態快照技能，用於立即總結對話進展並持久化存檔。

## 🌟 核心功能

- **數據深度提取**：自動分析當前對話，提取「已完成範圍」、「技術細節」、「審核結果」、「測試驗證」與「Git 提交」等維度。
- **標準化模板**：產出具備 YAML Frontmatter 的 Obsidian 格式 Markdown。
- **雲端同步**：自動存檔至 `/Users/yj/我的雲端硬碟/OpenClaw Agents/01_Obsidian/09_memory-snapshot/`。

## 🚀 使用方式

當一個重大開發步驟完成、或需要結束當前對話時，請輸入：

```bash
/snapshot
```

或是要求：
> 「幫我做個 snapshot」

## 📂 檔案結構

- `SKILL.md`: 快照定義與存檔邏輯。

---
#memory-snapshot #session-management #obsidian #openclaw
