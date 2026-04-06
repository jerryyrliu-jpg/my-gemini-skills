---
name: snapshot
description: 立即總結本次對話的所有重大進展，產出工業級的 Session Snapshot 並存入雲端硬碟記憶庫。
---

# Snapshot: 工業級 Session 記憶快照技能

當使用者輸入 /snapshot 或要求總結對話時，請執行以下程序：

## 1. 核心規範 (Hard Mandates)
- **必須包含 Hashtags**: 在 YAML 與 正文標題下方必須包含關鍵標籤。
- **必須包含日期標籤**: 格式固定為 #yyyy-mm-dd (例如 #2026-04-06)。
- **格式對齊**: 嚴格遵守提供的工業級總結模板。

## 2. 數據分析 (Session Analysis)
掃描當前對話歷史，提取以下維度：
- Implemented Scope: 已完成的功能範圍（條列式）。
- Implementation Details: 具體的代碼異動、新增檔案、修改的邏輯。
- Review Outcome: 過程中發現的 Bug 與修正。
- Verification: 執行的測試指令與結果。
- Git Outcome: 提交的 Commit SHA。

## 3. 格式模板 (Template)
```markdown
---
title: [主題名稱] Implementation And Summary
date: YYYY-MM-DD
tags:
  - memory-snapshot
  - [專案名稱]
  - #YYYY-MM-DD
aliases:
  - [主題簡寫] Summary
---

# [主題名稱] Implementation And Summary

#memory-snapshot #[專案名稱] #[關鍵字] #YYYY-MM-DD

## Summary
[概括目標與成果]

## Implemented Scope
- [功能清單]

## Implementation Details
[技術細節與路徑]

## Review Outcome
[審查發現與修復]

## Verification
- **Result**: [測試結果]

## Git Outcome
- **Commit**: [SHA]

## Current Status
[系統狀態]
```

## 4. 實體操作 (Action)
1. 存檔路徑：/Users/yj/我的雲端硬碟/OpenClaw Agents/01_Obsidian/09_memory-snapshot/YYYY-MM-DD_[主題名稱]_Summary.md。
