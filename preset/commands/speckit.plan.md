---
description: "Execute the implementation planning workflow using the plan template to generate design artifacts."
argument-hint: "Optional guidance for the planning phase"
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before planning)**:
- Check if `.specify/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_plan` key
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally
- Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
- For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
  - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
  - If the hook defines a non-empty `condition`, skip the hook
- When constructing command invocations from hook command names, replace dots (`.`) with hyphens (`-`).
- For each executable hook, output based on its `optional` flag (same pattern as speckit.specify).
  - **Mandatory hook**: emit `EXECUTE_COMMAND:` and wait for result before continuing.
  - **Optional hook**: display prompt and command.
- If no hooks are registered or `.specify/extensions.yml` does not exist, skip silently

## Outline

1. **Setup**: Run `.specify/scripts/bash/setup-plan.sh --json` from repo root and parse JSON for FEATURE_SPEC, IMPL_PLAN, SPECS_DIR, BRANCH.

2. **Load context**: Read FEATURE_SPEC and `.specify/memory/constitution.md`. Load IMPL_PLAN template (already copied by setup script).

4. **Execute plan workflow** — fill the plan template sections:

   a. **Overview** (from spec.md):
      - **Problem Statement**: Summarize from spec's Pain Point
      - **Target Users**: Table from spec's Who section
      - **Success Metrics**: Quantifiable outcomes derived from spec's Desired Outcome and User Journeys

   b. **Capability Tree** (functional decomposition):
      - Identify high-level capability domains from the spec
      - For each capability, enumerate features with:
        - Description, Inputs, Outputs, Behavior
        - **Supports**: Which PRD journey IDs (J1, J2, ...) this feature helps satisfy
      - Every feature must reference at least one journey. If a feature supports no journey, question whether it's needed.

   c. **Journey Contracts** (bridge PRD journeys to tests):
      - For each User Journey (J1, J2, ...) from spec.md, define:
        - **Tier**: API (headless integration test) or Playwright (browser-based E2E)
        - **Setup**: Preconditions — data and state
        - **Action**: HTTP request or browser interaction
        - **Assert**: Observable result — status code + response shape, or DOM state
      - The contract must be specific enough for an agent to write a test skeleton
      - Not so detailed that it prescribes implementation (no mock setup, no stubs)

   d. **Structural Decomposition** (code organization):
      - Map capabilities to repository file/folder structure
      - Repository Structure tree with NEW/MODIFIED annotations
      - Module Definitions with exports

   e. **Architecture**:
      - System Components, Data Models, Technology Stack
      - Key Design Decisions with Rationale, Trade-offs, Alternatives considered
      - Request flow diagrams where applicable

   f. **Risks**:
      - Technical risks (complexity, unknowns)
      - Dependency risks (blocking issues)
      - Scope risks (creep, underestimation)
      - Each with Impact, Likelihood, Mitigation, Fallback

   g. **Appendix**: References, Glossary, Open Questions

5. **Write plan.md** to `FEATURE_DIR/plan.md`.

## Mandatory Post-Execution Hooks

**You MUST complete this section before reporting completion to the user.**

Check if `.specify/extensions.yml` exists in the project root.
- If it does not exist, or no hooks are registered under `hooks.after_plan`, skip to the Completion Report.
- If it exists, read it and look for entries under the `hooks.after_plan` key.
- Same hook processing rules as Pre-Execution Checks.

## Completion Report

Report completion with:
- Plan file path (`FEATURE_DIR/plan.md`)
- Number of capabilities and features identified
- Number of journey contracts defined (should match spec.md journey count)
- Key design decisions made
- Readiness for `/speckit-tasks`

## Key Rules

- Every capability feature must reference at least one PRD journey via **Supports**
- Every PRD journey must have a Journey Contract with tier, setup, action, assert
- Journey Contracts define WHAT to assert, not HOW to set up mocks
- Use absolute paths for filesystem operations; project-relative paths for references in docs

## Done When

- [ ] Plan written to `FEATURE_DIR/plan.md` with all template sections filled
- [ ] Every feature has a Supports field linking to PRD journeys
- [ ] Every PRD journey (J1, J2, ...) has a Journey Contract
- [ ] Extension hooks dispatched or skipped
- [ ] Completion reported to user
