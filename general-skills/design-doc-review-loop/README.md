# Design Doc Review Loop (設計文件評核循環)

這是一個專為 Gemini CLI 設計的進階技能，用於在正式開發或規劃之前，對設計文件（Design Doc）進行標準化的「研究 -> 策略 -> 評核」循環。

## 🌟 核心功能

- **腦暴整合**：與 `brainstorming` 技能深度結合，引導設計方向。
- **標準化文檔**：自動要求包含範圍、目標、架構、數據契約與測試策略的工業級規範。
- **Agent 評核機制**：由專門的評核 Agent 進行審查，並給予明確的 `pass / fail / decompose` 判定。
- **迭代修復**：支援多達 20 輪的審查與修正循環，確保設計在動工前達到「No findings」狀態。

## 🚀 使用方式

當您準備開始一個重大功能或架構重構時，請呼叫：

```bash
/design-doc-review-loop <主題名稱>
```

## 📂 檔案結構

- `SKILL.md`: 核心邏輯與工作流定義。
- `agents/openai.yaml`: 評核 Agent 的介面定義。

---
#ai-agent #design-review #software-architecture #gemini-cli
