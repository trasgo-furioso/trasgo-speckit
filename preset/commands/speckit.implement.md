---
description: "Execute the implementation plan by processing BDD/TDD phases from tasks.md"
argument-hint: "Optional implementation guidance or task filter"
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before implementation)**:
- Check if `.specify/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_implement` key
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

1. Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute.

2. **Check checklists status** (if FEATURE_DIR/checklists/ exists):
   - Scan all checklist files in the checklists/ directory
   - For each checklist, count total, completed, and incomplete items
   - **If any checklist is incomplete**: STOP and ask user whether to proceed
   - **If all checklists are complete**: Automatically proceed

3. **Load implementation context**:
   - **REQUIRED**: Read tasks.md — the BDD/TDD phase plan with journey references and test contracts
   - **REQUIRED**: Read plan.md — capability tree, journey contracts, architecture, repository structure
   - **REQUIRED**: Read spec.md — user journeys (J1, J2, ...), problem statement, assumptions
   - **IF EXISTS**: Read data-model.md, contracts/, research.md, quickstart.md
   - **IF EXISTS**: Read .specify/memory/constitution.md for governance constraints

4. **Project Setup Verification**:
   - **REQUIRED**: Create/verify ignore files based on actual project setup:

   **Detection & Creation Logic**:
   - Check if the following command succeeds to determine if the repository is a git repo (create/verify .gitignore if so):

     ```sh
     git rev-parse --git-dir 2>/dev/null
     ```

   - Check if Dockerfile* exists or Docker in plan.md → create/verify .dockerignore
   - Check if .eslintrc* exists → create/verify .eslintignore
   - Check if eslint.config.* exists → ensure the config's `ignores` entries cover required patterns
   - Check if .prettierrc* exists → create/verify .prettierignore
   - Check if .npmrc or package.json exists → create/verify .npmignore (if publishing)
   - Check if terraform files (*.tf) exist → create/verify .terraformignore
   - Check if .helmignore needed (helm charts present) → create/verify .helmignore

   **If ignore file already exists**: Verify it contains essential patterns, append missing critical patterns only
   **If ignore file missing**: Create with full pattern set for detected technology

   **Common Patterns by Technology** (from plan.md tech stack):
   - **Node.js/JavaScript/TypeScript**: `node_modules/`, `dist/`, `build/`, `*.log`, `.env*`
   - **Python**: `__pycache__/`, `*.pyc`, `.venv/`, `venv/`, `dist/`, `*.egg-info/`
   - **Java**: `target/`, `*.class`, `*.jar`, `.gradle/`, `build/`
   - **C#/.NET**: `bin/`, `obj/`, `*.user`, `*.suo`, `packages/`
   - **Go**: `*.exe`, `*.test`, `vendor/`, `*.out`
   - **Ruby**: `.bundle/`, `log/`, `tmp/`, `*.gem`, `vendor/bundle/`
   - **PHP**: `vendor/`, `*.log`, `*.cache`, `*.env`
   - **Rust**: `target/`, `debug/`, `release/`, `*.rs.bk`, `*.rlib`
   - **Swift**: `.build/`, `DerivedData/`, `*.swiftpm/`, `Packages/`
   - **Universal**: `.DS_Store`, `Thumbs.db`, `*.tmp`, `*.swp`, `.vscode/`, `.idea/`

   **Tool-Specific Patterns**:
   - **Docker**: `node_modules/`, `.git/`, `Dockerfile*`, `.dockerignore`, `*.log*`, `.env*`, `coverage/`
   - **ESLint**: `node_modules/`, `dist/`, `build/`, `coverage/`, `*.min.js`
   - **Prettier**: `node_modules/`, `dist/`, `build/`, `coverage/`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
   - **Terraform**: `.terraform/`, `*.tfstate*`, `*.tfvars`, `.terraform.lock.hcl`

5. **Parse tasks.md structure** — extract:
   - **Dependency chain**: Foundation → dependent layers, with journey references
   - **BDD/TDD phases**: Each phase has a journey reference, BDD task (first), TDD tasks, and exit command
   - **Phase ordering**: Topological order from the dependency chain
   - **Exit commands**: Runnable test commands that prove each phase is complete

6. **Execute phases in dependency order.** For each phase:

   a. **Announce phase**: Display the phase name, journey reference, and entry criteria.

   b. **BDD task (FIRST)**: Write the failing integration test.
      - Read the journey contract from plan.md (tier, setup, action, assert)
      - Expand into the full executable test (setup, stubs, assertions, test file path)
      - Write the test file
      - Run the exit command — it MUST fail (red). If it passes, the test is not testing new behavior.
      - Commit the failing test

   c. **TDD tasks (sequential)**: For each TDD task in the phase:
      - Read the test contract (inputs → expected outputs)
      - Write the failing unit test from the contract
      - Implement the minimal code to make it pass
      - Run the unit test — it MUST pass (green)
      - Commit the test + implementation together

   d. **BDD verification**: After all TDD tasks complete:
      - Run the phase's exit command (the BDD integration test)
      - If it passes: phase is complete, mark all tasks as `[X]`
      - If it fails: debug the integration gap — the TDD tasks pass individually but don't integrate. Fix, re-run, repeat.

   e. **Mark completion**: Update tasks.md — mark all phase tasks as `[X]`

7. **Phase execution rules**:
   - **Phases are sequential**: Complete each phase before starting the next (dependency chain)
   - **BDD test is always first**: Never skip the failing integration test
   - **TDD tasks are sequential within a phase**: Each builds on the previous
   - **Each TDD cycle = one commit**: Test + implementation committed together
   - **Exit command is the gate**: Phase is not done until the exit command passes
   - **Never skip the exit command**: Even if all TDD tasks pass, run the BDD test to verify integration

8. **Progress tracking and error handling**:
   - Report progress after each completed TDD task
   - Report phase completion with exit command result
   - If a TDD task's unit test won't pass after implementation: halt, report the failure with context
   - If the BDD test won't pass after all TDD tasks: report the integration gap, suggest debugging steps
   - **IMPORTANT**: For completed tasks, mark them as `[X]` in tasks.md

9. **Completion validation**:
   - Verify all phases are complete (all exit commands pass)
   - Verify all tasks in tasks.md are marked `[X]`
   - Run the full test suite if a command is provided in the test strategy section
   - Confirm implementation matches the spec's user journeys

Note: This command assumes tasks.md contains BDD/TDD phases with journey contracts. If tasks.md uses a different format, suggest running `/speckit-tasks` first to regenerate.

## Mandatory Post-Execution Hooks

**You MUST complete this section before reporting completion to the user.**

Check if `.specify/extensions.yml` exists in the project root.
- If it does not exist, or no hooks are registered under `hooks.after_implement`, skip to the Completion Report.
- If it exists, read it and look for entries under the `hooks.after_implement` key.
- Same hook processing rules as Pre-Execution Checks.

## Completion Report

Report final status with:
- Phases completed (with journey references)
- Exit commands that passed
- Total tasks completed
- Any integration issues encountered and how they were resolved

## Done When

- [ ] All BDD/TDD phases completed — exit commands pass
- [ ] All tasks in tasks.md marked `[X]`
- [ ] Implementation validated against spec user journeys
- [ ] Extension hooks dispatched or skipped
- [ ] Completion reported to user
