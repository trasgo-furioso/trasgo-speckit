---
description: "Create or update the feature specification from a natural language feature description."
argument-hint: "Describe the feature you want to specify"
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before specification)**:
- Check if `.specify/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_specify` key
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally
- Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
- For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
  - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
  - If the hook defines a non-empty `condition`, skip the hook and leave condition evaluation to the HookExecutor implementation
- When constructing command invocations from hook command names, replace dots (`.`) with hyphens (`-`). For example, `speckit.git.commit` → `/speckit-git-commit`.
- For each executable hook, output the following based on its `optional` flag:
  - **Optional hook** (`optional: true`):
    ```
    ## Extension Hooks

    **Optional Pre-Hook**: {extension}
    Command: `/{command}`
    Description: {description}

    Prompt: {prompt}
    To execute: `/{command}`
    ```
  - **Mandatory hook** (`optional: false`):
    ```
    ## Extension Hooks

    **Automatic Pre-Hook**: {extension}
    Executing: `/{command}`
    EXECUTE_COMMAND: {command}

    Wait for the result of the hook command before proceeding to the Outline.
    ```
    After emitting the block above you MUST actually invoke the hook and wait for it to finish before continuing.
- If no hooks are registered or `.specify/extensions.yml` does not exist, skip silently

## Outline

The text the user typed after `/speckit-specify` in the triggering message **is** the feature description. Assume you always have it available in this conversation even if `$ARGUMENTS` appears literally below.

Given that feature description, do this:

1. **Generate a concise short name** (2-4 words) for the feature:
   - Use action-noun format when possible (e.g., "user-auth", "fix-payment-timeout")
   - Preserve technical terms and acronyms

2. **Branch creation** (optional, via hook):
   If a `before_specify` hook ran successfully in the Pre-Execution Checks above, it will have created/switched to a git branch and output JSON containing `BRANCH_NAME` and `FEATURE_NUM`. Note these values for reference.

3. **Create the spec feature directory**:
   Specs live under the default `specs/` directory unless the user explicitly provides `SPECIFY_FEATURE_DIRECTORY`.

   **Resolution order for `SPECIFY_FEATURE_DIRECTORY`**:
   1. If the user explicitly provided `SPECIFY_FEATURE_DIRECTORY`, use it as-is
   2. Otherwise, auto-generate it under `specs/`:
      - Check `.specify/init-options.json` for `feature_numbering`
      - If `"timestamp"`: prefix is `YYYYMMDD-HHMMSS`
      - If `"sequential"` or absent: prefix is `NNN` (next available 3-digit number after scanning existing directories in `specs/`)
      - Construct: `<prefix>-<short-name>`
      - Set `SPECIFY_FEATURE_DIRECTORY` to `specs/<directory-name>`

   **Create the directory and spec file**:
   - `mkdir -p SPECIFY_FEATURE_DIRECTORY`
   - Resolve the active `spec-template` through the Spec Kit preset/template resolution stack
   - Copy the resolved `spec-template` file to `SPECIFY_FEATURE_DIRECTORY/spec.md` as the starting point
   - Set `SPEC_FILE` to `SPECIFY_FEATURE_DIRECTORY/spec.md`
   - Persist the resolved path to `.specify/feature.json`:
     ```json
     { "feature_directory": "<resolved feature dir>" }
     ```

4. Load the resolved active `spec-template` file to understand required sections.

5. **IF EXISTS**: Load `.specify/memory/constitution.md` for project principles.

6. **Begin the discovery conversation.** The user's initial input (from `$ARGUMENTS`) is the starting point. Analyze it to determine which spec sections already have partial coverage and which are missing.

7. **Adaptive topic exploration.** Maintain an internal coverage map tracking these required sections:

   | Section | Status |
   |---------|--------|
   | Pain Point | empty / partial / complete |
   | Who | empty / partial / complete |
   | Current Alternatives | empty / partial / complete |
   | Desired Outcome | empty / partial / complete |
   | Jobs to Be Done | empty / partial / complete |
   | User Journeys | empty / partial / complete |
   | Assumptions | empty / partial / complete |

   Ask about the least-covered topic first. Follow the natural conversation flow rather than a fixed sequence. Assume users have product sense and can navigate the exploration.

8. **One question at a time.** Ask exactly one question per turn. Wait for the user's response before asking the next question.

9. **Challenge vague statements.** When the user provides vague or non-specific answers, push back with a targeted follow-up:
   - Non-specific audiences ("everyone", "all users") → ask for a specific user segment or persona
   - Unmeasurable outcomes ("better", "faster", "more intuitive") → ask what that means in observable or measurable terms
   - Undefined scope ("and more", "etc.") → ask for specific examples
   - Missing specifics ("some kind of") → ask for concrete details
   - Non-testable "then" clauses ("it works", "it's correct") → ask what specifically can be asserted
   Do not challenge answers that are already specific enough.

10. **Incremental persistence.** After each topic reaches sufficient coverage, ask the user: "Want me to save this progress to spec.md?" If yes, write the current state to `SPEC_FILE`. If no, continue but note that unpersisted content may be lost if the session is interrupted.

11. **Section-specific guidance:**

    - **Pain Point**: What breaks, fails, or frustrates — be specific about the observable symptom. No solutions.
    - **Who**: Specific personas, their roles, and how they're affected. Reject "all users".
    - **Current Alternatives**: What users do today — workarounds, alternative tools, or nothing. "None" is valid.
    - **Desired Outcome**: What changes for the user — observable and measurable, no implementation language.
    - **Jobs to Be Done**: 3-6 statements in "When [situation], I want to [motivation], so I can [outcome]" format. Each independent.
    - **User Journeys**: Testable scenarios in "Given [precondition], when [action], then [observable result]" format. Number each: J1, J2, J3... The "then" clause must state an observable, verifiable result. No implementation language. Each journey is independent.
    - **Assumptions**: Falsifiable statements about current state (data, user, technical, scope).

12. **Criteria-based completion.** When all required sections reach "complete" status, nudge the user: "The spec covers all required topics. You can continue refining or say 'done' to finalize." The user can always continue adding detail.

13. **Session finalization.** When the user says "done":
    - Write the final spec to `SPEC_FILE` with all sections populated from the conversation
    - Run quality validation (step 14)

14. **Specification Quality Validation**: After writing the spec, validate against the PRD Quality Checklist:

   - [ ] **Pain Point** describes a user-visible problem, not a solution
   - [ ] **Who** names specific personas with concrete impacts — not "all users"
   - [ ] **Current Alternatives** is honest — workarounds, nothing, or first occurrence
   - [ ] **Desired Outcome** is observable and measurable — no implementation language
   - [ ] **Jobs to Be Done** use the When/Want/So format with independent statements
   - [ ] **User Journeys** use Given/When/Then with observable "then" clauses
   - [ ] **User Journeys** are numbered (J1, J2, ...) and each is independent
   - [ ] **User Journeys** contain no implementation language
   - [ ] **Assumptions** are falsifiable and relevant to scope decisions
   - [ ] No solution language leaked into any section
   - [ ] A reader who knows nothing about the codebase can understand the problem

   If items fail: fix and re-validate (max 3 iterations).

15. **Abort handling.** If the user wants to abort:
    - If no content has been persisted yet, exit without creating artifacts
    - If incremental saves have already been made, warn that a partial spec.md exists and offer to delete it or keep it as-is

## Mandatory Post-Execution Hooks

**You MUST complete this section before reporting completion to the user.**

Check if `.specify/extensions.yml` exists in the project root.
- If it does not exist, or no hooks are registered under `hooks.after_specify`, skip to the Completion Report.
- If it exists, read it and look for entries under the `hooks.after_specify` key.
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue to the Completion Report.
- Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
- For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
  - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
  - If the hook defines a non-empty `condition`, skip the hook
- When constructing command invocations from hook command names, replace dots (`.`) with hyphens (`-`).
- For each executable hook, output the following based on its `optional` flag:
  - **Mandatory hook** (`optional: false`) — **You MUST emit `EXECUTE_COMMAND:` for each mandatory hook**:
    ```
    ## Extension Hooks

    **Automatic Hook**: {extension}
    Executing: `/{command}`
    EXECUTE_COMMAND: {command}
    ```
    After emitting the block above you MUST actually invoke the hook and wait for it to finish before continuing.
  - **Optional hook** (`optional: true`):
    ```
    ## Extension Hooks

    **Optional Hook**: {extension}
    Command: `/{command}`
    Description: {description}

    Prompt: {prompt}
    To execute: `/{command}`
    ```

## Completion Report

Report completion to the user with:
- `SPECIFY_FEATURE_DIRECTORY` — the feature directory path
- `SPEC_FILE` — the spec file path
- Number of user journeys generated (J1, J2, ...)
- Readiness for the next phase (`/speckit-plan`)

## Quick Guidelines

- Focus on **WHAT** hurts and **WHO** it hurts — never HOW to fix it
- User Journeys must be testable: Given/When/Then with observable "then" clauses
- No implementation language in any section (no tech stack, APIs, code structure)
- Make informed defaults; limit [NEEDS CLARIFICATION] to max 3

## Done When

- [ ] Specification written to `SPEC_FILE` with all PRD sections populated
- [ ] All user journeys numbered (J1, J2, ...) with observable assertions
- [ ] Quality checklist passes
- [ ] Extension hooks dispatched or skipped
- [ ] Completion reported to user
