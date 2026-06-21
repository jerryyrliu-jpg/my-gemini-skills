# Human-Agent-in-the-Loop Development Skill

## Description
This skill defines the Human-Agent-in-the-Loop (HAIL) development workflow, ensuring proper design, plan writing, and multi-stage adversarial reviews (using subagents and humans) before any implementation code is written.

## Version
1.0.0

## Change List
- **v1.0.0 (Initial Release)**: 
  - Designed the 9-phase Human-Agent-in-the-Loop (HAIL) planning workflow.
  - Implemented the custom loop controller script `hail-loop.sh` to track workflow state.
  - Created initial documentation (`SKILL.md`, `README.md`).

## Code Structure
```
human-agent-in-the-loop-development/
├── SKILL.md               # Main Antigravity skill definition (English)
├── README.md              # Skill documentation (this file)
└── scripts/
    └── hail-loop.sh       # Custom workflow controller and state manager
```

## Workflow Diagram

```mermaid
graph TD
  Start([Start Task]) --> DiscussPhase["(1) Discuss Direction & Architecture"]
  DiscussPhase --> WriteDesignDoc["(2) Write Design Document"]
  WriteDesignDoc --> HumanReviewDoc["(3) Human Initial Review"]
  HumanReviewDoc --> SubagentReviewDoc["(4) Subagent Review Doc Loop"]
  SubagentReviewDoc --> CheckDocIssues{"Are there Design Issues?"}
  
  CheckDocIssues -- "Yes" --> WriteDesignDoc
  CheckDocIssues -- "No" --> HumanReviewDocOptional["(5) Human Re-review Doc (Optional)"]
  
  HumanReviewDocOptional --> WritePlan["(6) Write Execution Plan"]
  WritePlan --> SubagentReviewPlan["(7) Subagent Review Plan Loop"]
  SubagentReviewPlan --> CheckPlanIssues{"Are there Plan Issues?"}
  
  CheckPlanIssues -- "Yes" --> WritePlan
  CheckPlanIssues -- "No" --> HumanFinalReview["(8) Human Final Review"]
  
  HumanFinalReview --> ImplementPhase["(9) Enter Implementation & Verification"]
```
