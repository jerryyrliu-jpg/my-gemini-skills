---
**Version:** v1.0

name: web
description: Unified web browsing - fast content extraction + interactive browsing with safety guards
metadata:
  { "openclaw": { "emoji": "🌐" } }
---

# Web Skill

Unified entry point for all web operations. Automatically routes to the best backend:
- **smart-fetch** (Node.js) — fast, token-efficient content extraction
- **browser** (Python/Playwright) — search, screenshots, page interaction

## Usage

```bash
web <command> [options]
```

## Commands

### Content Extraction (smart-fetch backend)
Best for: reading articles, scraping data, API docs.

| Command | Description |
|---------|-------------|
| `web fetch <url>` | Fetch page content as text |
| `web fetch <url> --selector "css"` | Extract specific elements only (saves tokens) |
| `web fetch <url> --readability` | Auto-clean article content |
| `web fetch <url> --proxy` | Use US proxy (bypass geo-restrictions) |
| `web fetch <url> --format json` | Output as JSON (also: markdown, text) |
| `web fetch <url> --screenshot out.png` | Save screenshot while fetching |
| `web fetch urls.txt --batch` | Process multiple URLs from file |
| `web fetch <url> --wait 3000` | Wait for dynamic content (ms) |

### Search & Interaction (browser backend)
Best for: Google search, dynamic pages, clicking buttons.

| Command | Description |
|---------|-------------|
| `web search --query "term"` | Google search, returns top 10 results |
| `web screenshot --url <url> --name x` | Full-page screenshot → screenshots/x.png |
| `web click --url <url> --selector "#btn"` | Click element (requires user approval) |
| `web scroll --url <url>` | Scroll to bottom (load lazy content) |

## When to Use What

| Scenario | Command |
|----------|---------|
| Read an article/docs | `web fetch <url> --readability` |
| Extract specific data | `web fetch <url> --selector "table.data"` |
| US-only content | `web fetch <url> --proxy` |
| Find information online | `web search --query "..."` |
| See how a page looks | `web screenshot --url <url>` |
| Interact with a page | `web click --url <url> --selector "..."` |

## Safety

- Browser backend blocks sensitive domains (bank, paypal, login, etc.)
- All browsing is headless, sandboxed, no cookies/sessions
- Click actions require human approval

---

## 🛡️ 聯邦安全與資源規範 (v3.5 Hardened)
1. **RAM 監控**: 執行任務前必須檢查系統 Free Memory > 20% (2GB)。
2. **自動銷毀**: 臨時對話 Session (-p) 獲取結果後必須即刻銷毀。
3. **運算優化**: 後台與自動化任務優先選用 `gemini-2.5-flash-lite`。
