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
2. **Intelligent Deep Analysis**: Analyze the transcript to provide a structured, multi-layered report:
   - **核心主旨 (Core Mission)**: One sentence summarizing the video's primary goal.
   - **內容深度分析 (Deep Breakdown)**: Detailed explanation of the video's structure, key arguments, and specific techniques or examples mentioned.
   - **實作建議 (Actionable Advice)**: List concrete steps or applications for the viewer based on the content.
3. **Key Takeaways**: Provide 5-8 bullet points of high-value, specific insights.
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
