# Codebase Decompose — Implementation Plan

## Problem Statement

Developers using AI coding assistants waste tokens and wall-clock time because agents repeatedly scan the same codebase structure every session. There's no structured, pre-built documentation to consult instead.

## Target Users

| Persona | Workflow | Pain |
|---------|----------|------|
| Developer using Claude Code (or similar) | Asks AI to reason about project structure, APIs, data model | Waits and pays tokens while agent re-scans source code from scratch |

## Success Metrics

- AI agents consult `docs/` artifacts before scanning source code (measured by AGENTS.md directive adoption)
- Incremental updates preserve unchanged content (no full regeneration on each run)
- All 6 artifact types maintain cross-referenced ID integrity (J→C→E→contracts)

---

## Capability Tree

### Capability: Codebase Scanning

#### Feature: Tech Stack Auto-Detection
- **Description**: Detect project technology stack from signature files and adapt scanning strategy
- **Inputs**: Project root directory (package.json, Gemfile, go.mod, Cargo.toml, pom.xml, pyproject.toml, etc.)
- **Outputs**: Detected stack metadata (language, framework, ORM, API style)
- **Behavior**: Check for signature files and dependency manifests. Determines which contract format to use (REST, GraphQL, CLI, WebSocket, messaging) and which schema extraction strategy to follow.
- **Supports**: J7

#### Feature: Parallel Codebase Exploration
- **Description**: Scan the codebase across 5 focused domains using parallel Explore agents
- **Inputs**: Project root, detected tech stack, user arguments (focus areas, change descriptions)
- **Outputs**: Raw findings per domain (API surface, core logic, integrations, data model, infrastructure)
- **Behavior**: Launch up to 5 Explore agents in a single message with Agent tool calls. Each agent scans a scoped area: (1) API surface and entry points, (2) core logic and domain services, (3) integrations and external boundaries, (4) data model and validation, (5) infrastructure and module wiring. If `$ARGUMENTS` specifies a focus area, give that agent "very thorough" and others "quick".
- **Supports**: J1, J7

### Capability: Delta Detection

#### Feature: Baseline Loading
- **Description**: Load existing `docs/` artifacts and extract structured inventory of IDs
- **Inputs**: `docs/` directory contents (if exists)
- **Outputs**: Baseline inventory: list of J-IDs, C-IDs, E-IDs, endpoint paths, file tree entries
- **Behavior**: Read all target files. If a file is missing or empty, mark for full generation. If it has content, parse its structure (journey IDs, capability IDs, entity IDs, file paths) as the baseline.
- **Supports**: J2

#### Feature: Change Classification
- **Description**: Compare scan results against baseline to classify each finding
- **Inputs**: Scan results, baseline inventory
- **Outputs**: Classification per item: ADDED, REMOVED, or MODIFIED
- **Behavior**: New IDs not in baseline → ADDED. Baseline IDs not found in scan → REMOVED. IDs with changed content → MODIFIED. Unchanged items preserved verbatim.
- **Supports**: J2

### Capability: Artifact Generation

#### Feature: User Journeys Generation
- **Description**: Generate `docs/user-journeys.md` with project-level J-prefixed journey IDs
- **Inputs**: Scan findings (end-to-end workflows, actors, systems)
- **Outputs**: `docs/user-journeys.md` with `## J1 — Title` entries
- **Behavior**: Each journey describes who the actor is, what they do, what systems are involved, and the outcome. Sequential IDs (J1, J2, ...). On delta update, preserve existing IDs, append new at end, never reuse deleted IDs.
- **Supports**: J1, J2

#### Feature: Capability Tree Generation
- **Description**: Generate `docs/capability-tree.md` with C-prefixed domain and feature IDs
- **Inputs**: Scan findings (services, controllers, handlers, business logic)
- **Outputs**: `docs/capability-tree.md` with `## C1 — Domain` / `### C1.1 Feature` entries
- **Behavior**: Each feature has Description, Inputs, Outputs, Behavior, and Supports (referencing J-IDs). Every feature must reference at least one journey. Domains numbered C1, C2..., features C1.1, C1.2...
- **Supports**: J1, J2

#### Feature: Structural Decomposition Generation
- **Description**: Generate `docs/structural-decomposition.md` with repo tree, dependency graph, capability-to-code map
- **Inputs**: Scan findings (file tree, module wiring, dependency injection, cross-cutting concerns)
- **Outputs**: `docs/structural-decomposition.md` with annotated file tree, ASCII dependency graph, C-ID to file path map
- **Behavior**: Repository tree only includes files that actually exist. Capability-to-code map stays in sync with capability-tree.md IDs. Cross-cutting concerns identified separately.
- **Supports**: J1, J2, J3

#### Feature: Data Model Generation
- **Description**: Generate `docs/data-model.md` with E-prefixed entity IDs
- **Inputs**: Scan findings (schemas, models, DTOs, migrations, validation rules)
- **Outputs**: `docs/data-model.md` with `## E1 — EntityName` entries
- **Behavior**: Each entity has Fields (name, type, constraints), Relationships (cardinality, FK), Validation rules, State Transitions (if applicable), and Supports (referencing C-IDs). Derived from actual schema definitions, not runtime code assumptions.
- **Supports**: J1, J2, J5

#### Feature: Interface Contracts Generation
- **Description**: Generate `docs/contracts/*.md` with auto-detected interface types
- **Inputs**: Scan findings (routes, endpoints, CLI commands, WebSocket events, message queues)
- **Outputs**: One markdown file per interface type (e.g., `rest-api.md`, `websocket-api.md`, `cli.md`)
- **Behavior**: Auto-detect project interface types. Each endpoint/event/command references the capability it implements via `Implements: C1.2`. Grouped by domain using capability-tree.md domain names. Skip entirely if project has no external interfaces.
- **Supports**: J1, J2, J4

#### Feature: AGENTS.md Generation
- **Description**: Generate `docs/AGENTS.md` — the documentation-first research directive
- **Inputs**: All other generated artifacts (file paths, ID summaries)
- **Outputs**: `docs/AGENTS.md` with lookup table and rules
- **Behavior**: Runs last (depends on all other artifacts). Creates a lookup table mapping "Need to know..." queries to the correct doc file and what scanning it replaces. Includes static rules instructing AI agents to consult docs before scanning source code.
- **Supports**: J3, J4, J5, J6

### Capability: Changelog Tracking

#### Feature: Changelog Comments
- **Description**: Prepend HTML changelog comments to each generated artifact
- **Inputs**: Delta classification results, current date
- **Outputs**: `<!-- Decomposition updated: YYYY-MM-DD ... -->` comment at top of each file
- **Behavior**: First generation uses "Decomposition created: YYYY-MM-DD". Updates list Added/Removed/Modified items. Placed below the title heading.
- **Supports**: J2

### Capability: Preset Integration

#### Feature: Command Packaging
- **Description**: Package the decompose command following preset conventions
- **Inputs**: Command prompt content
- **Outputs**: `preset/commands/speckit.decompose.md` with YAML frontmatter, hooks, outline, completion report, done-when
- **Behavior**: Follows identical structure to existing speckit commands. Declares `hooks.before_decompose` / `hooks.after_decompose` for extensibility.
- **Supports**: J1

#### Feature: Converge Feedback Loop
- **Description**: Teach speckit-converge to detect docs/ staleness and emit a decompose update task
- **Inputs**: Converge's existing gap analysis findings, `docs/` artifacts
- **Outputs**: An additional convergence task in tasks.md referencing `/speckit-decompose` with atomic argument
- **Behavior**: During converge's Step 4 (Assess Codebase), also check whether implementation changes affect areas documented in `docs/`. If so, append one task: `Run /speckit-decompose "<atomic description of what changed>"`.
- **Supports**: J8

---

## Journey Contracts

### J1: Fresh Decompose — Generate All Artifacts
- **Tier**: API (CLI execution)
- **Setup**: A project with source code and at least one recognizable tech stack file (e.g., `package.json`, `Gemfile`). No `docs/` directory exists.
- **Action**: Run `/speckit-decompose`
- **Assert**: `docs/` directory created with: `user-journeys.md`, `capability-tree.md`, `structural-decomposition.md`, `data-model.md`, at least one file in `contracts/`, and `AGENTS.md`. Each file contains cross-referenced IDs (J-, C-, E- prefixes). AGENTS.md lookup table references all other doc files. Each capability has `Supports: J*`. Each entity has `Supports: C*`.

### J2: Delta Update — Incremental Changes
- **Tier**: API (CLI execution)
- **Setup**: A project with existing `docs/` artifacts from a prior decompose run. Source code has changed since last run.
- **Action**: Run `/speckit-decompose`
- **Assert**: Unchanged content preserved. New items appear as ADDED in changelog. Removed items deleted from docs. Modified items updated. Changelog comment at top of each changed file lists the delta. No ID collisions with existing IDs.

### J3: AI Reads Structure Instead of Scanning
- **Tier**: API (agent behavior)
- **Setup**: Project with `docs/structural-decomposition.md` and `docs/AGENTS.md` present.
- **Action**: AI agent needs to know project file structure.
- **Assert**: AGENTS.md lookup table directs to `docs/structural-decomposition.md` with entry "Instead of scanning: Running `ls`, `find`, or `Glob` across source tree." The file contains a complete annotated directory tree and capability-to-code mapping.

### J4: AI Reads API Docs Instead of Scanning
- **Tier**: API (agent behavior)
- **Setup**: Project with `docs/contracts/rest-api.md` (or equivalent) and `docs/AGENTS.md`.
- **Action**: AI agent needs to know API endpoints.
- **Assert**: AGENTS.md directs to relevant contract file with entry "Instead of scanning: Reading route and controller files." Contract file contains endpoint definitions with methods, paths, auth, request/response schemas.

### J5: AI Reads Data Model Instead of Scanning
- **Tier**: API (agent behavior)
- **Setup**: Project with `docs/data-model.md` and `docs/AGENTS.md`.
- **Action**: AI agent needs to know database entities.
- **Assert**: AGENTS.md directs to `docs/data-model.md` with entry "Instead of scanning: Reading schema/migration files." Data model contains entity definitions with fields, types, relationships, validation rules.

### J6: Speckit Commands Benefit Indirectly
- **Tier**: API (indirect — no command modification)
- **Setup**: Project with `docs/AGENTS.md` loaded in agent context (via project CLAUDE.md or AGENTS.md).
- **Action**: Developer runs `/speckit-plan` on a feature.
- **Assert**: The agent session includes AGENTS.md doc-first research instructions. The agent consults `docs/` before scanning source code when reasoning about project structure for the plan. No explicit `docs/` loading code exists in speckit commands.

### J7: Auto-Detect Tech Stack
- **Tier**: API (CLI execution)
- **Setup**: Project with a tech stack manifest (e.g., `Gemfile` for Ruby, `package.json` for Node) but no explicit stack argument.
- **Action**: Run `/speckit-decompose`
- **Assert**: Command detects the stack. Contract file format matches the detected API style (REST for Rails routes, GraphQL for GraphQL schema, CLI for CLI tools). Data model extraction uses the correct strategy for the detected ORM/schema layer. No user intervention needed.

### J8: Converge Feedback Loop
- **Tier**: API (CLI execution)
- **Setup**: A feature has been implemented. `docs/` exists from prior decompose. New code has changed APIs, data model, or project structure.
- **Action**: Run `/speckit-converge`
- **Assert**: Converge appends a task to `tasks.md` with instruction like: `Run /speckit-decompose "added POST /api/v2/widgets endpoint and Widget entity"`. The task includes an atomic description of what changed. The task appears in the Convergence phase section.

---

## Repository Structure

```
trasgo-speckit/
├── preset/
│   ├── preset.yml                          # MODIFIED — add speckit.decompose command
│   ├── commands/
│   │   ├── speckit.specify.md
│   │   ├── speckit.plan.md
│   │   ├── speckit.tasks.md
│   │   ├── speckit.implement.md
│   │   └── speckit.decompose.md            # NEW — core decompose command prompt
│   └── templates/
│       ├── spec-template.md
│       ├── plan-template.md
│       └── tasks-template.md
├── .claude/
│   └── skills/
│       ├── speckit-decompose/
│       │   └── SKILL.md                    # NEW — skill wrapper for Claude Code
│       └── speckit-converge/
│           └── SKILL.md                    # MODIFIED — add decompose feedback loop
├── bundle.yml                              # NO CHANGE — references preset by ID
├── README.md                               # MODIFIED — add decompose to pipeline docs
└── specs/
    └── 001-codebase-decompose/
        ├── spec.md
        ├── plan.md                         # (this file)
        └── tasks.md                        # (next phase)
```

## Module Definitions

### Module: speckit.decompose command
- **Maps to capability**: Codebase Scanning, Delta Detection, Artifact Generation, Changelog Tracking
- **Responsibility**: The full decompose workflow as a single command prompt
- **File**: `preset/commands/speckit.decompose.md`
- **Structure**: YAML frontmatter → User Input → Pre-Execution Checks (hooks) → Outline (16 steps) → Post-Execution Hooks → Completion Report → Done When

### Module: speckit-decompose skill
- **Maps to capability**: Preset Integration (Command Packaging)
- **Responsibility**: Skill wrapper enabling `/speckit-decompose` invocation in Claude Code
- **File**: `.claude/skills/speckit-decompose/SKILL.md`
- **Structure**: YAML frontmatter (name, description, compatibility, metadata, user-invocable) → delegates to command body (self-contained, like other skills)

### Module: Converge integration
- **Maps to capability**: Preset Integration (Converge Feedback Loop)
- **Responsibility**: Detect docs/ staleness during converge gap analysis, emit decompose update task
- **File**: `.claude/skills/speckit-converge/SKILL.md` (modification)
- **Changes**: Add docs/ staleness check to Step 4 (Assess Codebase), add decompose task emission pattern to Step 7 (Append Convergence Tasks)

---

## Architecture

### System Components

The decompose command is a **prompt-only** artifact — no runtime code, no scripts. It instructs the AI agent to:

1. **Scan** the codebase using Explore agents (via the Agent tool)
2. **Compare** scan results against existing docs (delta detection)
3. **Write** Markdown files to `docs/`

The output `docs/AGENTS.md` is the **behavioral contract** that teaches AI agents to consult docs before scanning. This is the mechanism by which all other speckit commands benefit indirectly.

### Data Models

No database or persistent data models. The "data" is structured Markdown with cross-referenced IDs:

| ID Namespace | Location | Format | Cross-references |
|---|---|---|---|
| J1, J2, ... | `docs/user-journeys.md` | `## J1 — Title` | Referenced by capabilities (Supports) |
| C1, C1.1, ... | `docs/capability-tree.md` | `## C1 — Domain` / `### C1.1 Feature` | Supports → J-IDs, referenced by entities and contracts |
| E1, E2, ... | `docs/data-model.md` | `## E1 — EntityName` | Supports → C-IDs |
| Endpoints | `docs/contracts/*.md` | `### METHOD /path` | Implements → C-IDs |

These are **project-level** IDs, distinct from feature-level J1/J2 IDs in `specs/*/spec.md`.

### Technology Stack

- **Language**: Markdown (prompt engineering)
- **Runtime**: Claude Code agent (or compatible AI coding assistant)
- **Dependencies**: Spec Kit >= 0.15.0 (for preset system), Agent tool (for parallel Explore agents)

### Key Design Decisions

**Decision: Parallel Agents via Agent Tool**
- **Rationale**: The source skill uses 5 parallel Explore agents for comprehensive scanning. Claude Code supports launching multiple Agent tool calls in a single message. This is significantly faster than sequential scanning.
- **Trade-offs**: More token usage per run (5 concurrent agent contexts), but dramatically less wall-clock time.
- **Alternatives**: Sequential scan phases (slower but simpler prompt). Rejected because the whole point is reducing time spent.

**Decision: No Template File**
- **Rationale**: Unlike specify/plan/tasks which fill a user-customizable template, decompose generates artifacts from scratch based on code scanning. The artifact schemas are integral to the command instructions — there's no meaningful user customization of output format.
- **Trade-offs**: The command file will be longer than others. Artifact schemas are defined inline rather than in separate template files.
- **Alternatives**: Create 6 template files (one per artifact). Rejected — adds indirection without benefit since these formats are fixed by the decompose methodology.

**Decision: `docs/` as Project-Level Output (Not Feature-Level)**
- **Rationale**: Decompose produces project-wide documentation, not feature-specific artifacts. The `specs/NNN-feature/` directories are for feature design; `docs/` is for aggregated codebase knowledge.
- **Trade-offs**: The command does not use `setup-plan.sh` or feature directory resolution. It operates directly on project root → `docs/`.
- **Alternatives**: Put decompose output in `.specify/docs/`. Rejected — docs should be visible in the project root for discoverability.

**Decision: Converge Integration via Lightweight Staleness Check**
- **Rationale**: J8 requires converge to detect docs/ staleness. This should be minimal to avoid bloating converge's already complex prompt.
- **Trade-offs**: Converge only detects overlap between implementation changes and documented areas — it doesn't do full delta analysis. The decompose command handles granularity.
- **Alternatives**: Make converge always emit a decompose task. Rejected — wasteful if docs are already current.

---

## Technical Risks

**Risk: Command prompt length**
- **Impact**: High — could exceed effective instruction length for some models
- **Likelihood**: Medium — the command must define 5 scan phases, 6 artifact schemas, delta detection logic, and tech stack heuristics
- **Mitigation**: Structure prompt with clear section boundaries. Use concise artifact schemas with one example each. Reference hook boilerplate as "same pattern as speckit.specify" rather than repeating.
- **Fallback**: If too long, extract artifact schema definitions into a separate reference file that the command instructs the agent to read.

**Risk: Scan quality varies by project type**
- **Impact**: Medium — wrong contract format, missed entities, incomplete structure
- **Likelihood**: Medium — unconventional project structures may not match heuristics
- **Mitigation**: Support `$ARGUMENTS` for explicit stack override. Fall back to generic scanning if no stack detected. The user argument hint documents this.
- **Fallback**: User manually edits docs/ after generation.

**Risk: Delta detection false positives**
- **Impact**: Low — unnecessary doc updates, not data loss
- **Likelihood**: Medium — content comparison is heuristic; renamed entities may appear as REMOVED+ADDED
- **Mitigation**: Compare by ID and semantic content, not raw text. Normalize formatting before comparison.
- **Fallback**: User reviews changelog comments.

## Dependency Risks

**Risk: Spec Kit preset system compatibility**
- **Impact**: Medium — command declaration may not work with future Spec Kit versions
- **Likelihood**: Low — preset.yml schema is stable
- **Mitigation**: Follow exact same declaration pattern as existing commands. No novel manifest features.

## Scope Risks

**Risk: Artifact schema scope creep**
- **Impact**: Medium — adding more artifact types or fields makes the command harder to maintain
- **Likelihood**: Medium — the source skill's schemas are comprehensive
- **Mitigation**: Port the source skill's schemas as-is for v1. Refinements are future work.
- **Fallback**: Start with the 4 core artifacts (journeys, capabilities, structure, data model) and add contracts + AGENTS.md in a follow-up.

---

## References

- Source skill: `/Users/trasgofurioso/Code/clara-messenger/.claude/skills/trasgospec-decompose/SKILL.md`
- Source output examples: `/Users/trasgofurioso/Code/clara-messenger/docs/`
- Existing command pattern: `preset/commands/speckit.specify.md`
- Existing skill pattern: `.claude/skills/speckit-analyze/SKILL.md`

## Glossary

| Term | Definition |
|------|-----------|
| Decompose | Project-level codebase analysis producing structured documentation artifacts |
| Delta detection | Comparing current scan results against existing docs to identify additions, removals, modifications |
| AGENTS.md | Documentation-first research directive — lookup table teaching AI to consult docs before scanning |
| Project-level IDs | J1, C1.1, E1 identifiers in `docs/` — distinct from feature-level IDs in `specs/` |

## Open Questions

1. Should the decompose command be addable to `.specify/extensions.yml` hooks (e.g., as `hooks.after_implement` to auto-update docs after every implement run), or is the converge feedback loop sufficient?
2. Should `docs/AGENTS.md` content also be injected into the project's `CLAUDE.md` or `.cursorrules` for automatic loading, or is the file's presence in `docs/` enough?
