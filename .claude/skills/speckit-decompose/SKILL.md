---
name: "speckit-decompose"
description: "Decompose the current project into user journeys, capability tree, structural decomposition, data model, interface contracts, and agent research directives. Delta-aware: updates existing docs with additions, removals, and modifications."
argument-hint: "Context, focus areas, or directives for the decomposition (e.g. 'focus on new auth module', 'this is a Go microservice', 'only update structural decomposition')"
compatibility: "Any codebase, any stack"
metadata:
  author: "trasgo-furioso"
user-invocable: true
disable-model-invocation: false
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty). The input may contain:
- **Context** about the project, its stack, or its purpose — use this to guide exploration and terminology
- **Focus areas** — concentrate scanning depth on the specified area while still maintaining overall consistency
- **Directives** — specific instructions about what to generate, update, or skip
- **Change descriptions** — what recently changed in the codebase, guiding delta detection

If the input is empty, perform a full decomposition of the entire project.

## Pre-Execution Checks

**Check for extension hooks (before decomposition)**:
- Check if `.specify/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_decompose` key
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

## Goal

Produce or update six documentation artifacts that together form a complete functional, structural, and contractual decomposition of the current project:

1. `docs/user-journeys.md` — High-level user journeys (who does what, end-to-end)
2. `docs/capability-tree.md` — Functional decomposition: capability domains → features with Description, Inputs, Outputs, Behavior, Supports (journey references)
3. `docs/structural-decomposition.md` — Code organization: repository tree, module dependency graph, capability-to-code map, cross-cutting concerns
4. `docs/data-model.md` — Domain entities: name, fields, types, relationships, validation rules, state transitions
5. `docs/contracts/` — Interface contracts: auto-detected format appropriate for the project type (REST endpoints, CLI commands, library exports, WebSocket events, message queue schemas, etc.). Skipped if the project is purely internal with no external interfaces.
6. `docs/AGENTS.md` — Documentation-First Research directive: a lookup table mapping information needs to the correct doc file, plus rules for agents to consult docs before scanning source code. Auto-generated after all other docs are written.

## Execution Flow

### Phase 1: Load Existing Documentation

Read all target files if they exist. Record their current state:
- If a file is missing or empty, mark it for full generation.
- If a file has content, parse its structure (journey IDs, capability IDs, entity IDs, file paths) to use as the baseline for delta detection.

```
Read docs/user-journeys.md
Read docs/capability-tree.md
Read docs/structural-decomposition.md
Read docs/data-model.md
Read docs/contracts/*.md (all files in the contracts directory)
Read docs/AGENTS.md
```

Also read any project-level context files that exist (README, CLAUDE.md, AGENTS.md, or equivalent) to understand the project's self-described purpose and stack.

### Phase 2: Scan the Codebase

First, identify the project's technology stack, entry points, and directory conventions by reading top-level files (package.json, Cargo.toml, go.mod, pyproject.toml, pom.xml, Makefile, or equivalent). Adapt your exploration strategy to the stack found.

If `$ARGUMENTS` provides context about the stack or focus area, use it to prioritize and shape your exploration.

Launch up to 5 Explore agents **in parallel** (a single message with multiple Agent tool calls) to scan the codebase comprehensively. Each agent gets a focused area:

**Agent 1 — API Surface, Entry Points & Interface Contracts**: Scan all public interfaces, route definitions, command handlers, endpoint declarations, RPC definitions, CLI commands, WebSocket events, message queue topics, or equivalent entry points. For each, identify: the operation, its path/name, HTTP method (if applicable), what handler processes it, what it does, authentication/authorization requirements, request schema (parameters, body, headers), response schema (shape, status codes), and error responses. Group by domain. This agent's output feeds both the capability tree and the interface contracts.

**Agent 2 — Core Logic & Domain Services**: Scan all business logic modules (services, use cases, domain models, handlers, or equivalent). For each, identify: module name, public operations, dependencies, and business purpose. Identify the core interaction patterns.

**Agent 3 — Integrations & External Boundaries**: Scan all external integration points (third-party APIs, messaging systems, storage backends, auth providers, or equivalent). For each, identify: what it integrates with, its interface, capabilities provided, and how it connects to the core system.

**Agent 4 — Data Model & Validation**: Scan data definitions (schemas, models, DTOs, types, migrations, validation rules, auth/authorization mechanisms, configuration). For each domain entity, extract: entity name, all fields with types and constraints (required, unique, enum, default, range, regex), relationships to other entities with cardinality (1:1, 1:N, M:N) and foreign keys, and state transitions (status/lifecycle enums, allowed transitions between states). Also identify validation rules that exist in application code beyond the schema layer. This agent's output feeds both the capability tree and the data model.

**Agent 5 — Infrastructure & Module Wiring**: Scan entry points, dependency injection, module composition, middleware, caching, error handling, utilities, and deployment configuration. Identify the bootstrap sequence, dependency graph, cross-cutting concerns, and deployment architecture.

If `$ARGUMENTS` specifies a focus area, give that area's agent(s) a "very thorough" directive and the others a "quick" scan. If `$ARGUMENTS` describes recent changes, direct agents to specifically examine those areas for deltas.

### Phase 3: Delta Detection

Compare the codebase scan results against the existing documentation baseline:

For **user-journeys.md**:
- Identify new end-to-end workflows enabled by code not covered by existing journeys
- Identify journeys that reference capabilities no longer present in code
- Identify journeys whose description no longer accurately reflects the code

For **capability-tree.md**:
- Identify new capabilities (new endpoints, services, integrations) not documented
- Identify documented capabilities whose code has been removed
- Identify capabilities where Inputs, Outputs, or Behavior have changed
- Ensure every capability's **Supports** field references valid journey IDs

For **structural-decomposition.md**:
- Identify new files/directories not in the repository tree
- Identify documented files that no longer exist
- Identify changes to the module dependency graph (new modules, removed wiring)
- Update the capability-to-code map for any capability changes
- Identify new or removed cross-cutting concerns

For **data-model.md**:
- Identify new entities (new schemas, models, tables) not in existing doc
- Identify documented entities whose definitions have been removed from code
- Identify entities where fields, relationships, validation rules, or state transitions have changed
- Ensure every entity's **Supports** field references valid capability IDs

For **contracts/**:
- Identify new external interfaces (endpoints, commands, events) not documented
- Identify documented interfaces that no longer exist in code
- Identify interfaces where request/response schemas, auth requirements, or behavior have changed
- If the project type changed (e.g., added a WebSocket layer), determine if a new contract file is needed

Classify each finding as: **ADDED**, **REMOVED**, or **MODIFIED**.

If `$ARGUMENTS` describes what changed (e.g., "I added a new Kafka integration"), use that as a primary signal and verify it against the scan results rather than doing blind diffing.

### Phase 4: Generate or Update Files

Create the `docs/` directory if it does not exist.

For each file, apply the delta:
- **Full generation** (file missing/empty): Write the complete document from scan results.
- **Delta update** (file has content): Merge changes into the existing document. Preserve manually-added content that is still valid. Remove items confirmed deleted from code. Add new items. Update modified items.

Prepend an HTML comment changelog at the top of each file (below the title):

```markdown
<!--
Decomposition updated: YYYY-MM-DD
Added: C16.1 New Feature, J12 New Journey, ...
Removed: C7.5 Deprecated Bot, ...
Modified: C2.3 Send Audio (new FFmpeg pipeline), ...
-->
```

If this is the first generation (no previous content), use:
```markdown
<!--
Decomposition created: YYYY-MM-DD
-->
```

#### Format: user-journeys.md

```markdown
# User Journeys

## J1 — Title
A one-paragraph description of the end-to-end journey: who the actor is,
what they do, what systems are involved, and what the outcome is.

## J2 — Title
...
```

Rules:
- Each journey has a sequential ID: J1, J2, J3...
- When updating, preserve existing IDs. Append new journeys at the end with the next available ID.
- Never reuse a deleted journey's ID in the same run.

#### Format: capability-tree.md

```markdown
# Capability Tree (Functional Decomposition)

## C1 — Domain Name

### C1.1 Feature Name
- **Description**: What this feature does
- **Inputs**: Parameters, payloads, data structures
- **Outputs**: What is returned or emitted
- **Behavior**: How it works, key implementation details, platform/provider differences
- **Supports**: J1, J3 (which journeys this feature enables)

### C1.2 Another Feature
...

---

## C2 — Another Domain
...
```

Rules:
- Domains are numbered C1, C2, C3... Features within a domain are C1.1, C1.2...
- Every feature MUST reference at least one journey in **Supports**. If a feature supports no journey, question whether it belongs.
- When updating, preserve existing IDs. Append new domains/features at the end.
- Group by logical domain using the project's own terminology.

#### Format: structural-decomposition.md

```markdown
# Structural Decomposition (Code Organization)

## Repository Structure
(annotated file tree with comments explaining each file/directory)

## Module Dependency Graph
(ASCII diagram showing how modules wire together)

## Capability to Code Location Map
### C1 Domain Name
- **Primary**: file paths of main implementation
- **Supporting**: file paths of data models, schemas, middleware

### C2 Another Domain
...

## Cross-Cutting Concerns
### Concern Name
- **Implementation**: file paths and description
- **Used by**: which parts of the system
```

Rules:
- Repository tree MUST only include files that actually exist (verify via scan).
- Annotate new files with `# NEW` and removed entries should simply be deleted.
- The capability-to-code map MUST stay in sync with capability-tree.md IDs.

#### Format: data-model.md

```markdown
# Data Model

## E1 — EntityName
- **Fields**:
  - `fieldName` (Type, required/optional, unique, default: value)
  - `status` (Enum: active | inactive | archived)
  - ...
- **Relationships**:
  - → EntityB (1:N via `entityB_id` FK)
  - ← EntityC (M:N via join table `entity_a_entity_c`)
  - ...
- **Validation**:
  - fieldName: min 3 chars, max 255, regex: ^[a-z]+$
  - Business rule: cannot archive if has active children
  - ...
- **State Transitions** (if applicable):
  - `status`: draft → active → archived; draft → deleted
  - Transition triggers: describe what causes each transition
- **Supports**: C1.1, C3.2 (which capabilities use this entity)

## E2 — AnotherEntity
...
```

Rules:
- Entities are numbered E1, E2, E3...
- When updating, preserve existing IDs. Append new entities at the end with the next available ID.
- Never reuse a deleted entity's ID in the same run.
- Every entity MUST reference at least one capability in **Supports**. If an entity supports no capability, question whether it belongs.
- Derive entity definitions from actual schema/model definitions (Prisma, SQL, TypeORM, Mongoose, Zod schemas, etc.), not from runtime code assumptions.
- Include **State Transitions** only when the entity has a status/lifecycle field with defined allowed transitions. Omit the section otherwise.

#### Format: contracts/ (interface contracts)

Create the `docs/contracts/` directory if it does not exist.

Auto-detect the project's interface types from the codebase scan and generate one markdown file per interface type. `$ARGUMENTS` can override the detected types or specify which contracts to generate.

Supported interface types and their file mappings:

- **REST/HTTP API** → `docs/contracts/rest-api.md`
- **GraphQL** → `docs/contracts/graphql-api.md`
- **CLI** → `docs/contracts/cli.md`
- **Library/SDK** → `docs/contracts/public-api.md`
- **WebSocket** → `docs/contracts/websocket-api.md`
- **Message Queues** → `docs/contracts/messaging.md`

If the project has no external interfaces (purely internal tools, build scripts, etc.), skip contract generation entirely and note this in the report.

```markdown
# REST API Contracts

## Domain Name (C1)

### POST /api/v1/resource
- **Implements**: C1.2 Create Resource
- **Auth**: API key required (header: `apikey`)
- **Request Body**:
  ```json
  {
    "name": "string (required, 3-255 chars)",
    "type": "enum: typeA | typeB"
  }
  ```
- **Success Response** (201):
  ```json
  {
    "id": "string",
    "name": "string",
    "createdAt": "ISO 8601"
  }
  ```
- **Error Responses**:
  - 400: Validation failed
  - 401: Missing or invalid API key
  - 409: Resource already exists
```

For non-REST interfaces, adapt the format:

**WebSocket contracts**: Document event names, message direction (client→server, server→client), payload schemas, and connection lifecycle.

**CLI contracts**: Document commands, subcommands, positional arguments, flags/options with types and defaults, stdin/stdout formats, and exit codes.

**Library/SDK contracts**: Document exported functions, classes, and types with their signatures, parameters, return types, and thrown exceptions.

**Message queue contracts**: Document topic/queue names, message schemas, publishing and consuming patterns, and delivery guarantees.

Rules:
- Group contracts by domain, using the same domain names as capability-tree.md.
- Every contract MUST reference the capability ID it implements via **Implements**.
- Include authentication/authorization requirements where applicable.
- Request/response schemas should reflect actual DTOs, validation rules, and types from the codebase.
- Changelog comment at the top of each contract file, same format as other docs.
- When updating, preserve existing entries. Append new endpoints/events at the end of their domain section.

#### Format: AGENTS.md (Documentation-First Research directive)

Generate this file **after** all other docs have been written, since its content depends on which docs exist.

```markdown
# Agents

## Documentation-First Research

The `docs/` directory contains authoritative, up-to-date documentation derived from the codebase. **Always consult these files before scanning source code for the same information.**

| Need to know... | Read first | Instead of scanning... |
|---|---|---|
| (row per generated doc file) | (doc path) | (what tool-based scanning it replaces) |

**Rules:**
1. Before launching Explore agents or doing broad codebase scans, read the relevant doc file(s) from the table above.
2. Use documentation as your starting point — only scan source code to verify details, find implementation specifics, or investigate areas not covered by docs.
3. When calling API endpoints (e.g., during debugging or testing), refer to the contracts docs for the correct method, path, auth headers, and request body — do not scan route files to figure out how to call an endpoint.
4. When reasoning about data relationships or entity fields, refer to `docs/data-model.md` — do not re-read schema files unless you need to verify a specific detail.
5. These docs are maintained by `speckit-decompose` and stay current with the codebase. Trust them as the source of truth for structural questions.
```

Rules:
- The lookup table MUST contain exactly one row for each doc file that was generated or already exists. Do not list docs that were skipped or don't exist.
- Standard rows for the core docs:
  - `docs/user-journeys.md` — "End-to-end user workflows" / "Inferring from code paths"
  - `docs/capability-tree.md` — "What features exist and how they connect" / "Scanning services and controllers"
  - `docs/structural-decomposition.md` — "File/directory structure" / "Running ls, find, or Glob across src/"
  - `docs/data-model.md` — "Database entities, fields, relationships" / "Reading schema/migration files"
- Add one row per contract file that was generated (e.g., `docs/contracts/rest-api.md`, `docs/contracts/websocket-api.md`). Adapt the "Need to know" and "Instead of scanning" columns to match the contract type.
- When updating, preserve any manually-added rows that reference valid doc files. Remove rows for docs that no longer exist.
- The Rules section is static — do not modify it unless the project's documentation strategy fundamentally changes.
- Changelog comment at the top, same format as other docs.

### Phase 5: Report

Output a summary to the user:

```
## Decomposition Summary

**Status**: Created / Updated
**Date**: YYYY-MM-DD

### Changes
- **Added**: (list of new items across all files)
- **Removed**: (list of removed items)
- **Modified**: (list of updated items)

### Coverage
- Journeys: N total
- Capability domains: N total, M features
- Entities: N total
- Interface contracts: N files (or "Skipped — no external interfaces detected")
- Files mapped: N

### Files Written
- docs/user-journeys.md
- docs/capability-tree.md
- docs/structural-decomposition.md
- docs/data-model.md
- docs/contracts/*.md (list each file generated, or note "Skipped")
- docs/AGENTS.md
```

## Mandatory Post-Execution Hooks

**You MUST complete this section before reporting completion to the user.**

Check if `.specify/extensions.yml` exists in the project root.
- If it does not exist, or no hooks are registered under `hooks.after_decompose`, skip to the Completion Report.
- If it exists, read it and look for entries under the `hooks.after_decompose` key.
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

## Important Guidelines

- Do NOT auto-commit. The user decides when to commit.
- Do NOT modify source code. This skill is read-only except for the `docs/` files (including `docs/contracts/`).
- Do NOT create files outside of `docs/`.
- When in doubt about whether something changed, include it as MODIFIED with a note.
- Prefer preserving existing prose and structure over rewriting from scratch.
- Adapt terminology to the project's stack and conventions. Use whatever language the codebase itself uses (e.g., "handlers" vs "controllers", "modules" vs "packages", "schemas" vs "models").
- Skip build output, vendor/dependency directories, and binary assets.
- If `$ARGUMENTS` directs you to only update specific files, still read all others for cross-reference consistency (journey IDs, capability IDs, entity IDs) but do not modify them.
- If the project has no external interfaces, skip contract generation entirely and note "Skipped — no external interfaces detected" in the report. Do not create empty contract files.
