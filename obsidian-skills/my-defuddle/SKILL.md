---
name: my-defuddle
description: Enhanced defuddle skill. For YouTube URLs, it provides a full analysis in Traditional Chinese, hashtags, and a date tag (#yyyy-mm-dd) alongside the transcript. For other sites, it extracts clean Markdown.
---

# My-Defuddle: Smart Content Extractor

This skill wraps the core `defuddle` logic with an advanced AI post-processing layer, optimized for YouTube content.

## Triggers
- `/my-defuddle <URL>`
- "Analyze this YouTube video: <URL>"
- "Clean and summarize this page: <URL>"

## Post-Processing Workflow

### 1. General Web Pages
- Run `defuddle parse <URL> --markdown`.
- Extract clean prose and structure it using standard Markdown.

### 2. YouTube Links (Enhanced Mode)
When the URL is from youtube.com or youtu.be:
1. **Raw Extraction**: Use `defuddle` to get the title, description, and transcript.
2. **Exhaustive Deep Analysis**: Analyze the transcript to provide a structured, high-signal report. **Do not omit any core tips, steps, or unique insights mentioned in the video.**
   - **核心主旨 (Core Mission)**: Use `> [!abstract]` to summarize the video's primary goal.
   - **內容深度詳解 (Deep Breakdown)**: Detailed explanation of every single technique, tip, or chapter mentioned. Use bullet points and sub-bullets for technical details.
   - **實作建議 (Actionable Advice)**: Use `> [!todo]` to list concrete steps or applications.
3. **Key Takeaways**: Provide 5-10 high-value, specific insights.
4. **Hashtags**: Generate 5+ relevant `#hashtags`.
5. **Obsidian Date Tag**: Append `#yyyy-mm-dd`.
6. **Output Format (Strict)**:
   - `# [Title]`
   - `## 💎 影片重點分析 (繁體中文)` (Contains Core Mission & Deep Breakdown)
   - `## 🚀 實作建議 (Actionable Advice)`
   - `## 📌 關鍵摘要 (Key Takeaways)`
   - `## 📜 完整逐字稿 (Full Transcript)`
     - *Insert the 100% complete raw text here.*
   - `## 標籤與日期`


## Implementation Rules
- Always use **Traditional Chinese** for analysis and summaries.
- If the transcript is in another language, translate the summary to Traditional Chinese.
- Ensure the `#yyyy-mm-dd` tag is correctly formatted for Obsidian compatibility.
