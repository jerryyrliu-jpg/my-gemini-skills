---
name: snapshot
description: 立即總結本次對話的所有重大進展，產出工業級的 Session Snapshot 並存入雲端硬碟記憶庫。
---

# Snapshot: 工業級 Session 記憶快照技能

當使用者輸入 /snapshot 或要求總結對話時，請執行以下程序：

## 1. 核心標籤規範 (Hashtag Mandates)
產出的 Markdown **必須** 在主標題下方包含一條完整的標籤鏈，包含以下維度：
- **#memory-snapshot**: 固定必填。
- **#[專案名稱]**: 本次作業的專案識別。
- **#[技術/主題]**: 例如 #gcs #infra #deployment (提取 2-3 個關鍵字)。
- **#yyyy-mm-dd**: 台北時間日期標籤 (例如 #2026-04-06)。

## 2. 數據分析 (Session Analysis)
掃描並提取：Implemented Scope, Implementation Details, Review Outcome, Verification, Git Outcome。

## 3. 格式模板 (Template)
```markdown
---
title: [主題名稱] Implementation And Summary
date: YYYY-MM-DD
tags:
  - memory-snapshot
  - [專案]
  - [關鍵字]
  - YYYY-MM-DD
---

# [主題名稱] Implementation And Summary

#memory-snapshot #[專案名稱] #[關鍵字1] #[關鍵字2] #YYYY-MM-DD

## Summary
...
```

## 4. 實體操作 (Action)
存檔路徑：/Users/yj/我的雲端硬碟/OpenClaw Agents/01_Obsidian/09_memory-snapshot/YYYY-MM-DD_[主題名稱]_Summary.md。
