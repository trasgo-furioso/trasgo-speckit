---
description: "Generate an actionable, dependency-ordered tasks.md with BDD/TDD phases driven by journey contracts."
argument-hint: "Optional task generation constraints"
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before tasks generation)**:
- Check if `.specify/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_tasks` key
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

1. **Setup**: Run `.specify/scripts/bash/setup-tasks.sh --json` from repo root and parse FEATURE_DIR, TASKS_TEMPLATE, and AVAILABLE_DOCS list. `FEATURE_DIR` and `TASKS_TEMPLATE` must be absolute paths when provided. `AVAILABLE_DOCS` is a list of document names/relative paths available under `FEATURE_DIR` (for example `research.md` or `contracts/`).

2. **Load design documents** from FEATURE_DIR:
   - **Required**: plan.md (capability tree, journey contracts, architecture), spec.md (user journeys, assumptions)
   - **Optional** (from AVAILABLE_DOCS): research.md (decisions), data-model.md (entities), contracts/ (interface contracts), quickstart.md (validation scenarios)
   - **IF EXISTS**: Load `.specify/memory/constitution.md` for project principles and governance constraints
   - Note: Not all projects have all documents. Generate tasks based on what's available.

4. **Execute task generation workflow**:

   a. **Extract from spec.md**: User Journeys (J1, J2, ...) and their given/when/then scenarios
   b. **Extract from plan.md**: Journey Contracts (tier, setup, action, assert), Capability Tree (features with Supports), Repository Structure
   c. **Build dependency chain**: Map modules in dependency order, annotate each with which journeys (J1, J2, ...) it supports
   d. **Generate BDD/TDD phases**: One phase per journey (or group of related journeys), following topological order

5. **Generate tasks.md** using the tasks template structure:

   ### Dependency Chain
   - Foundation Layer, then dependent layers
   - Each module states dependencies and which journeys it supports

   ### Development Phases — each phase is a BDD cycle:

   For each phase:
   - **Journey**: Which PRD journey (J1, J2, ...) this phase validates
   - **Entry Criteria**: What must exist before starting
   - **BDD** (first task): Write failing integration test from the plan's journey contract
     - Include the full contract: setup → action → expected result
     - Include the test file path
   - **TDD** (subsequent tasks): Each task provides a test contract (inputs → expected outputs)
     - The agent writes a failing unit test from the contract, implements until green
     - Each TDD cycle is a commit
   - **Exit**: A runnable command that proves the phase is complete (e.g., `bundle exec rspec path/to/spec.rb`)

   ### Test Strategy
   - BDD/TDD Cycle description for this project
   - Test Conventions (file locations, frameworks, how to run)
   - Edge Cases and Error Scenarios
   - Test Generation Guidelines

6. **Write tasks.md** to `FEATURE_DIR/tasks.md`.

## Phase Generation Rules

**Each phase MUST have**:
1. A journey reference (J1, J2, ...)
2. A BDD task as the FIRST task — write the failing integration test from the journey contract
3. TDD tasks with test contracts (inputs → expected outputs)
4. A runnable exit command

**BDD task contract format**:
```
- [ ] Write failing integration test `[test file path]`
      Contract: [setup from journey contract] → [action] → [expected result]
```

**TDD task contract format**:
```
- [ ] [Unit of work description]
      Contract: [inputs] → [expected outputs]
```

**Exit format** — must be a runnable command:
```
Exit: `bundle exec rspec spec/e2e/platform/feature_spec.rb`
```
or
```
Exit: `npx playwright test e2e/ux/feature_spec.ts`
```

**Bad examples** (do NOT produce these):
```
Exit Criteria: Storage works correctly.
```
```
- [ ] Implement the storage service
```
(No contract — agent won't write a test)

## Mandatory Post-Execution Hooks

**You MUST complete this section before reporting completion to the user.**

Check if `.specify/extensions.yml` exists in the project root.
- If it does not exist, or no hooks are registered under `hooks.after_tasks`, skip to the Completion Report.
- If it exists, read it and look for entries under the `hooks.after_tasks` key.
- Same hook processing rules as Pre-Execution Checks.

## Completion Report

Report completion with:
- Tasks file path (`FEATURE_DIR/tasks.md`)
- Number of phases generated
- Journey coverage: which journeys (J1, J2, ...) have BDD tests
- Number of TDD tasks per phase
- All exit commands listed

## Key Rules

- Every phase starts with a BDD task (failing integration test from journey contract)
- Every TDD task provides a test contract (inputs → expected outputs)
- Every phase exit is a runnable command — never free text
- Phases follow topological order of the dependency chain
- The tasks.md should be immediately executable — each task must be specific enough that an AI agent can complete it without additional context

## Done When

- [ ] tasks.md generated with BDD/TDD phases for all journeys
- [ ] Every phase has: journey reference, BDD first task with contract, TDD tasks with contracts, runnable exit command
- [ ] Dependency chain includes journey references
- [ ] Test strategy section filled with project-specific conventions
- [ ] Extension hooks dispatched or skipped
- [ ] Completion reported to user
