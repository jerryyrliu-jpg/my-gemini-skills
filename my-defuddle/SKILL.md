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
When the URL is from `youtube.com` or `youtu.be`:
1. **Raw Extraction**: Use `defuddle` to get the title, description, and transcript.
2. **Intelligent Summary**: Analyze the transcript and generate a **detailed summary in Traditional Chinese**.
3. **Key Insights**: List 3-5 bullet points of the most valuable takeaways.
4. **Hashtags**: Generate 3-5 relevant `#hashtags` based on the content.
5. **Obsidian Date Tag**: Append the current date in the format `#yyyy-mm-dd`.
6. **Output Format**:
   - `# [Title]`
   - `## 影片重點分析 (繁體中文)`
   - `## 關鍵摘要 (Key Insights)`
   - `## 完整逐字稿 (Full Transcript)`
     - *Insert the complete text extracted by defuddle here.*
   - `## 原始描述 (Original Description)`
   - `## 標籤與日期`

## Implementation Rules
- Always use **Traditional Chinese** for analysis and summaries.
- If the transcript is in another language, translate the summary to Traditional Chinese.
- Ensure the `#yyyy-mm-dd` tag is correctly formatted for Obsidian compatibility.
