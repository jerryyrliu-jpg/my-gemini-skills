---
name: design-doc-review-loop
description: Use when a user wants a design doc reviewed and iterated to approval before planning or implementation.
---

# Design Doc Review Loop

## Overview

Use this skill to run a fixed pre-implementation loop:
1. brainstorm the design,
2. write the design doc,
3. send it for agent review,
4. revise the doc,
5. repeat review and revision until the design passes.

Do not start implementation or planning work until the design doc has passed review.

## Workflow

### 1. Brainstorm First

Invoke `brainstorming` first.

Use it to:
- explore current repo context,
- ask clarifying questions one at a time,
- compare 2-3 approaches,
- present the recommended design,
- get user approval on the design direction.

If the idea is too large for one spec, decompose it and only run this loop for the first bounded sub-project.

### 2. Write The Design Doc

Once the design is approved, write the spec to:

`docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`

User path preferences override this default.

The document must make these explicit:
- problem and scope,
- goals and non-goals,
- architecture and key abstractions,
- data contracts and state transitions,
- error handling and edge cases,
- testing strategy,
- out-of-scope items.

Before review, do one quick self-pass:
- remove placeholders like `TODO` and `TBD`,
- resolve contradictions,
- tighten ambiguous wording,
- ensure the scope is still implementable as one plan.

### 3. Send The Design For Agent Review

Request one reviewer agent to evaluate the design doc as a spec review, not an implementation review.

Reviewer prompt should ask for:
- findings first, ordered by severity,
- concrete file and line references,
- primary focus on ambiguity, contradictions, missing contracts, sequencing problems, repo-fit issues, and missing tests,
- a final single-line verdict using exactly one of:
  - `pass`
  - `fail`
  - `decompose`

Give the reviewer enough local context to judge repo fit:
- the design doc path,
- the relevant repo/worktree,
- the key files or modules the spec must fit into.

Do not ask for generic suggestions or style commentary.

### 4. Triage Review Findings Technically

Invoke `receiving-code-review` before acting on review feedback.

Treat the reviewer as an external reviewer:
- verify each finding against the actual spec and codebase context,
- push back if the finding is not technically sound,
- only change the doc for real issues.

Do not perform fake agreement. Fix or reject findings with technical reasoning.

### 5. Revise The Design Doc

Update the design doc to resolve accepted findings.

When revising:
- patch the document directly,
- keep contracts executable and explicit,
- preserve approved scope unless the user changes it,
- avoid turning the doc into implementation detail that belongs in the plan.

After each revision, summarize:
- what changed,
- which findings were closed,
- any remaining open questions.

Use this per-round reporting template:

```text
Round N
Reviewer Verdict: pass | fail | decompose
Closed Findings:
- ...
Remaining Findings:
- ...
Doc Updated At:
- <path>
```

### 6. Repeat Until Pass

If the reviewer verdict is `fail`, loop back to review again.

Track review rounds explicitly.

- Start counting at round 1 for the first external design-doc review.
- Increment the counter once per full reviewer pass.
- The maximum is 20 review rounds.

Verdict handling is strict:
- `pass`: the design doc is approved and ready for `writing-plans`
- `fail`: the design doc has actionable issues but should stay in the same review loop
- `decompose`: stop the loop and split the work into smaller specs or return to brainstorming

Keep looping review and revision until one of these is true:
- the reviewer returns `pass`,
- the user decides to stop,
- the reviewer returns `decompose`,
- or 20 review rounds have been reached.

Stop early and convert to `decompose` when any of these happens:
- the same blocker category remains unresolved for 3 consecutive review rounds,
- the reviewer keeps saying the scope is too large or crosses multiple independent subsystems,
- the reviewer cannot judge repo fit because the spec lacks necessary codebase context,
- the design keeps changing at the problem-definition level instead of converging on executable contracts.

If 20 rounds are reached without `pass`:
- stop the loop,
- report that the design doc did not pass within the review limit,
- summarize the remaining blockers,
- ask the user whether to continue manually, narrow scope, or split the work into smaller specs.

### 7. Stop Or Hand Off

After the design doc passes review:
- tell the user the design doc is approved,
- state the final verdict as `pass`,
- offer the next step of invoking `writing-plans`.

Do not start implementation from this skill.

If the reviewer returns `decompose`:
- stop the loop,
- tell the user the current spec should not continue as a single design doc,
- recommend returning to `brainstorming` for decomposition before any plan is written.

## Review Contract

Use these rules consistently:
- Review the design doc, not the code diff.
- Findings must be concrete, not vague advice.
- Findings must target implementation-readiness of the spec.
- Line references are required whenever possible.
- If no issues remain, return verdict `pass`.
- Do not use verdict synonyms such as `approved`, `ready`, `implementation-plan-ready`, or `execution-ready`.

## Common Failure Modes

- Jumping from brainstorming straight to planning without an external review pass.
- Letting reviewer comments drift into implementation detail instead of spec contracts.
- Accepting weak feedback without checking repo reality.
- Declaring the design ready when major caveats still exist.
- Mixing user approval with reviewer approval; both are separate gates.
- Letting verdict wording drift away from `pass | fail | decompose`.

## Completion Signal

This skill is complete only when:
- the design doc exists on disk,
- and either:
  - the latest review verdict is `pass`,
  - the latest review verdict is `decompose` and the user has been told to split scope or return to brainstorming,
  - or the 20-round limit has been hit and the unresolved blockers have been reported to the user.

When the design passes, tell the user the spec is approved and ready for planning.
When the reviewer returns `decompose`, tell the user the current scope should be split before planning.
When the loop stops at the cap, tell the user the skill stopped because the 20-round review limit was reached.
