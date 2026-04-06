---
name: snapshot
description: 立即總結本次對話的所有重大進展，產出工業級的 Session Snapshot 並存入雲端硬碟記憶庫。
---

# Snapshot: 工業級 Session 記憶快照技能

當使用者輸入 /snapshot 或要求總結對話時，請執行以下程序：

## 1. 數據分析 (Session Analysis)
掃描當前對話歷史，提取以下維度：
- Implemented Scope: 已完成的功能範圍（條列式）。
- Implementation Details: 具體的代碼異動、新增檔案、修改的邏輯、採用的演算法或標準（如 Zlib RFC 1950）。
- Review Outcome: 過程中發現的 Bug、修正的架構錯誤、安全性建議。
- Verification: 執行的測試指令、測試結果斷言。
- Git Outcome: 提交的 Commit SHA、分支變更。
- Current Status: 系統目前的穩定狀態、接下來的預計動作。

## 2. 格式規範 (Template)
產出的 Markdown 必須嚴格遵守以下結構：

```markdown
---
title: [主題名稱] Implementation And Summary
date: YYYY-MM-DD
tags:
  - memory-snapshot
  - [專案名稱]
  - [關鍵字1]
  - [關鍵字2]
  - YYYY-MM-DD
aliases:
  - [主題簡寫] Summary
---

# [主題名稱] Implementation And Summary

#memory-snapshot #[專案名稱] #[關鍵字1] #YYYY-MM-DD

## Summary
[一小段概括本次 Session 的核心目標與最終成果]

## Implemented Scope
- [功能 1]
- [功能 2]

## Implementation Details
[詳述技術細節、檔案路徑與採用的架構設計]

## Review Outcome
[記錄審查發現的問題與最終修復方案]

## Verification
- **Baseline**: [測試前狀態]
- **Result**: [測試後結果，如 155 passed]

## Git Outcome
- **Commit**: [SHA]
- **Message**: [訊息]

## Current Status
[目前系統所處的狀態與後續建議]
```

## 3. 實體操作 (Action)
1.  自動生成標題：根據對話內容推導一個簡潔的標題。
2.  存檔路徑：寫入至 /Users/yj/我的雲端硬碟/OpenClaw Agents/01_Obsidian/09_memory-snapshot/YYYY-MM-DD_[主題名稱]_Summary.md。
3.  確認回報：完成後告知使用者檔案已存檔，並提供完整路徑。
