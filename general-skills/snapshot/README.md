# Snapshot Skill

工業級 Session 總結技能，專為 Gemini CLI 與 Obsidian 打造。

## 🌟 核心特性
- **自動化總結**: 提取實作範圍、技術細節與測試結果。
- **Hashtag 支援**: 產出的檔案自動包含 `#memory-snapshot` 與自定義標籤。
- **日期標記**: 強制包含 `#yyyy-mm-dd` 格式，對齊 Obsidian 檢索規範。
- **雲端同步**: 自動存入指定的 Google Drive 快照目錄。

## 🛠️ 安裝方式
將 `SKILL.md` 放置於 `~/.gemini/skills/snapshot/` 即可。

## 📋 使用規範
執行 `/snapshot` 後，Agent 將嚴格依照工業級模板產出具備雙層標籤架構的 Markdown 文件。
