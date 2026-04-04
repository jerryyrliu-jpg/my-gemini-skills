---
name: my-defuddle
description: Ultimate web & YouTube content extractor. Combines Kepano's original defuddle logic with enhanced YouTube analysis, Traditional Chinese summaries, and Obsidian-optimized formatting.
---

# My-Defuddle: Ultimate Content Extractor

This skill is a superset of the original `defuddle` skill, combining high-efficiency web parsing with advanced AI post-processing for YouTube and Obsidian.

## Description

Defuddle is designed to streamline web content ingestion. It strips away navigation menus, advertisements, and clutter, providing a lean Markdown version of articles and documentation to optimize token usage.

## Triggers

- `/my-defuddle <URL>`
- "extract article from <URL>"
- "clean this page: <URL>"
- "Analyze this YouTube video: <URL>"

## Usage & Mental Model

### 1. General Web Pages (Original Defuddle Logic)
Defuddle is a server-side HTML parser—it downloads HTML, strips boilerplate, and returns clean prose. It is faster and cheaper than browser-based fetch for standard pages.

**When to apply:**
- Standard HTTP pages (documentation, articles, blog posts, wikis).

**When NOT to apply:**
- Single Page Applications (SPAs) requiring JavaScript execution.
- Login-gated pages or pages behind authentication.
- JSON API endpoints.

### 2. YouTube Links (Enhanced AI Layer)
When the URL is from `youtube.com` or `youtu.be`:
1. **Raw Extraction**: Use `defuddle parse <URL> --markdown` to get the transcript.
2. **Exhaustive Deep Analysis**: **Do not omit any core tips, steps, or unique insights.**
   - **核心主旨 (Core Mission)**: Use `> [!abstract]` for the primary goal.
   - **內容深度詳解 (Deep Breakdown)**: Detailed explanation of every technique/chapter. Use nested bullet points.
   - **實作建議 (Actionable Advice)**: Use `> [!todo]` for concrete steps.
3. **Key Takeaways**: Provide 5-10 specific, high-value insights.
4. **Automated Metadata**: Generate 5+ `#hashtags` and append `#yyyy-mm-dd`.

## Output Format (Strict)

- `# [Title]`
- `## 💎 影片重點分析 (繁體中文)` (For YouTube) OR `## 📝 內容深度總結` (For Web)
- `## 🚀 實作建議 (Actionable Advice)`
- `## 📌 關鍵摘要 (Key Takeaways)`
- `## 📜 原始內容/逐字稿 (Full Content)`
  - *Insert the 100% complete raw text from defuddle here.*
- `## 標籤與日期`

## Implementation Rules
- Always use **Traditional Chinese** for analysis and summaries.
- Ensure the `#yyyy-mm-dd` tag is correctly formatted.
- **Data Integrity**: Never truncate the raw transcript or main prose in the "Full Content" section.

---
*Based on [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) with OpenClaw enhancements.*
