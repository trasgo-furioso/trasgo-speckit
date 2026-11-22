# Codebase Decompose

## Problem Statement

**Pain Point**: Developers using AI coding assistants (Claude Code, etc.) waste tokens and wall-clock time because agents repeatedly scan the same codebase structure, re-discovering what already exists, every time they need to reason about the project. Context is lost between sessions and there's no structured, pre-built documentation to consult instead.

## Who

- **Developers using AI coding assistants** — they pay the cost in both tokens and response latency as agents re-explore the codebase's file structure, API surfaces, data models, capabilities, and workflows from scratch on every session or task.

## Current Alternatives

**None**. Developers absorb the cost of repeated scanning, or context is simply lost between sessions. There is no established workaround.

## Desired Outcome

A developer's AI assistant can consult pre-built, up-to-date project documentation instead of re-scanning source code, reducing token usage and response latency when reasoning about the codebase.

## Jobs to Be Done

- When I need to know my project's file structure, I want to read a structural decomposition doc, so the AI doesn't burn tokens running `ls`, `find`, or `Glob` across the source tree.
- When I need to know what API endpoints exist (methods, paths, schemas), I want to read an interface contract doc, so the AI doesn't scan route and controller files.
- When I need to know database entities, fields, and relationships, I want to read a data model doc, so the AI doesn't re-read schema files.
- When I need to know what features exist and how they connect, I want to read a capability tree doc, so the AI doesn't scan services and controllers.
- When I need to understand end-to-end user workflows, I want to read a user journeys doc, so the AI doesn't infer them from code paths.
- When my codebase changes, I want these docs to update incrementally, so they stay trustworthy as the source of truth.

## User Journeys

- **J1**: Given a project has no `docs/` directory, when a developer runs the decompose command, then six interconnected documentation artifacts are generated (user-journeys, capability-tree, structural-decomposition, data-model, interface contracts, AGENTS.md) with cross-referenced IDs.

- **J2**: Given a project has existing `docs/` artifacts from a previous decomposition, when the codebase has changed and the developer runs the decompose command, then only the additions, removals, and modifications are applied to the existing docs — unchanged content is preserved.

- **J3**: Given the `docs/` artifacts exist, when an AI assistant needs to know the project's file structure, then it reads `docs/structural-decomposition.md` instead of scanning the source tree.

- **J4**: Given the `docs/` artifacts exist, when an AI assistant needs to know API endpoints or interface schemas, then it reads the relevant contract doc instead of scanning route/controller files.

- **J5**: Given the `docs/` artifacts exist, when an AI assistant needs to know database entities and relationships, then it reads `docs/data-model.md` instead of re-reading schema files.

- **J6**: Given the `docs/` artifacts exist, when a developer runs a speckit command (plan, tasks), then the command loads relevant `docs/` artifacts as shared context to reduce redundant codebase exploration.

- **J7**: Given a project uses a technology stack the developer hasn't specified, when the decompose command runs, then it auto-detects the stack and adapts its scanning strategy and contract format accordingly.

- **J8**: Given a feature has been implemented and speckit-converge runs its gap analysis, when new code has been built that changes the project's structure, capabilities, or data model, or any docs produced by decompose, then converge appends a task to run the decompose command with an atomic argument describing what changed, so `docs/` stays current with the codebase.

## Assumptions

1. The decompose command outputs to a project-level `docs/` directory, not inside feature-level `specs/` directories.
2. The speckit commands (plan, tasks, implement) benefit from decompose indirectly — the agent session has AGENTS.md loaded, which instructs it to consult `docs/` before scanning. No explicit `docs/` loading is needed in the commands themselves.
3. The AGENTS.md lookup table is the mechanism that teaches AI assistants to consult docs before scanning source code.
4. The decompose command follows the same preset packaging conventions as existing commands (YAML frontmatter, preset.yml declaration, pre/post hooks).
5. Interface contracts are auto-detected by project type (REST, GraphQL, CLI, WebSocket, etc.) — not all projects will produce all contract types.
6. The ID namespaces (J1 journeys, C1.1 capabilities, E1 entities) used by decompose are project-level and distinct from the feature-level J1/J2 IDs in speckit's spec.md files. `docs/` is aggregation; `specs/` is plan and design.
