# Codebase Decompose — Tasks

## Dependency Chain

### Foundation Layer (Phase 0)
No dependencies — built first.

- **speckit.decompose.md**: The core command prompt. Contains all scanning logic, delta detection, artifact schemas, tech stack detection. This is the main deliverable. Supports: J1, J2, J3, J4, J5, J7

### Integration Layer (Phase 1)
- **speckit-decompose SKILL.md**: Skill wrapper for Claude Code. Depends on [speckit.decompose.md content]. Supports: J1, J6
- **preset.yml**: Preset manifest declaration. Depends on [speckit.decompose.md file existing]. Supports: J1

### Feedback Layer (Phase 2)
- **speckit-converge SKILL.md**: Converge integration for docs/ staleness detection. Depends on [decompose command being defined]. Supports: J8

### Documentation Layer (Phase 3)
- **README.md**: Pipeline documentation update. Depends on [all command and integration work complete]. Supports: J1

---

## Development Phases

### Phase 0: Core Decompose Command
**Journey**: J1 — Fresh decompose generates all 6 artifacts; J2 — Delta update preserves unchanged content; J7 — Auto-detect tech stack

**Entry Criteria**: Source skill read and understood (`/Users/trasgofurioso/Code/clara-messenger/.claude/skills/trasgospec-decompose/SKILL.md`). Plan.md complete with capability tree and journey contracts.

**BDD**:
- [X]Write structural validation script `specs/001-codebase-decompose/validate-command.sh`
      Contract: Run against `preset/commands/speckit.decompose.md` →
      assert file exists, contains YAML frontmatter (`---`), contains all required sections
      (User Input, Pre-Execution Checks, Outline, Mandatory Post-Execution Hooks, Completion Report, Done When),
      contains all 5 scan phase references (API Surface, Core Logic, Integrations, Data Model, Infrastructure),
      contains all 6 artifact schema references (user-journeys.md, capability-tree.md, structural-decomposition.md, data-model.md, contracts/, AGENTS.md),
      contains delta detection logic (ADDED, REMOVED, MODIFIED),
      contains tech stack detection references (package.json, Gemfile, go.mod, Cargo.toml, pyproject.toml)

**TDD**:
- [X]Write YAML frontmatter and User Input section of `preset/commands/speckit.decompose.md`
      Contract: `description` field present → describes codebase decomposition;
      `argument-hint` field present → describes optional stack override or delta description;
      `$ARGUMENTS` placeholder present in User Input section

- [X]Write Pre-Execution Checks section (hooks.before_decompose)
      Contract: hook key = `hooks.before_decompose` →
      follows identical pattern to `preset/commands/speckit.specify.md` Pre-Execution Checks;
      handles enabled/disabled filtering, optional/mandatory dispatch, condition skipping

- [X]Write Outline Step 1-2: Resolve DOCS_DIR and load existing docs baseline
      Contract: DOCS_DIR = project-root/docs/ (not feature-level) →
      read all target files if they exist (user-journeys.md, capability-tree.md, structural-decomposition.md, data-model.md, contracts/*.md, AGENTS.md);
      if file missing/empty → mark for full generation;
      if file has content → parse structure (J-IDs, C-IDs, E-IDs, endpoint paths) as baseline inventory

- [X]Write Outline Step 3: Tech stack auto-detection
      Contract: scan project root for signature files (package.json, Gemfile, go.mod, Cargo.toml, pom.xml, pyproject.toml, Makefile, etc.) →
      output detected stack metadata (language, framework, ORM, API style);
      if `$ARGUMENTS` provides stack override → use that instead;
      if no stack detected → fall back to generic scanning;
      stack determines: contract format (REST/GraphQL/CLI/WebSocket/messaging), schema extraction strategy, scan path priorities

- [X]Write Outline Steps 4-8: Five parallel codebase scan phases
      Contract: instruct agent to launch up to 5 Explore agents in a single message with Agent tool calls →
      Agent 1: API Surface, Entry Points & Interface Contracts (routes, endpoints, CLI commands, RPC, WebSocket events, auth requirements, request/response schemas);
      Agent 2: Core Logic & Domain Services (business logic modules, public operations, dependencies, purpose);
      Agent 3: Integrations & External Boundaries (third-party APIs, messaging, storage, auth providers);
      Agent 4: Data Model & Validation (schemas, models, DTOs, migrations, validation rules, relationships, state transitions);
      Agent 5: Infrastructure & Module Wiring (entry points, DI, middleware, config, deployment);
      if `$ARGUMENTS` specifies focus area → "very thorough" for that agent, "quick" for others

- [X]Write Outline Step 9: Delta detection logic
      Contract: compare scan results against baseline inventory →
      new IDs not in baseline → ADDED;
      baseline IDs not found in scan → REMOVED;
      IDs with changed content → MODIFIED;
      unchanged items → preserve verbatim;
      if baseline is empty (first run) → all items are ADDED

- [X]Write Outline Steps 10-14: Artifact generation schemas (5 core artifacts)
      Contract: for each artifact, define the exact Markdown format inline:
      `docs/user-journeys.md` → `## J1 — Title` with actor, workflow, outcome (sequential IDs, never reuse deleted);
      `docs/capability-tree.md` → `## C1 — Domain` / `### C1.1 Feature` with Description, Inputs, Outputs, Behavior, Supports: J* (every feature must reference ≥1 journey);
      `docs/structural-decomposition.md` → annotated repo tree, ASCII dependency graph, C-ID to file path map, cross-cutting concerns;
      `docs/data-model.md` → `## E1 — EntityName` with Fields, Relationships, Validation, State Transitions, Supports: C* (derived from actual schema definitions);
      `docs/contracts/*.md` → one file per auto-detected interface type, grouped by domain, each entry has `Implements: C*`

- [X]Write Outline Step 15: AGENTS.md generation (depends on all other artifacts)
      Contract: generate `docs/AGENTS.md` last →
      contains lookup table with columns: "Need to know...", "Read first", "Instead of scanning...";
      one row per generated doc file;
      contains static rules: (1) read docs before Explore agents, (2) docs as starting point, (3) consult contracts for API calls, (4) consult data-model for entity questions, (5) docs maintained by decompose and trustworthy;
      changelog comment at top

- [X]Write Outline Step 16: Cross-reference integrity validation
      Contract: after all artifacts generated →
      every capability Supports field references valid J-IDs from user-journeys.md;
      every entity Supports field references valid C-IDs from capability-tree.md;
      every contract Implements field references valid C-IDs;
      AGENTS.md lookup table references all generated doc files;
      report any broken references

- [X]Write changelog comment generation logic
      Contract: first generation → `<!-- Decomposition created: YYYY-MM-DD -->`;
      delta update → `<!-- Decomposition updated: YYYY-MM-DD\nAdded: ...\nRemoved: ...\nModified: ... -->`;
      placed below title heading in each file

- [X]Write Mandatory Post-Execution Hooks section (hooks.after_decompose)
      Contract: hook key = `hooks.after_decompose` →
      follows identical pattern to `preset/commands/speckit.specify.md` Post-Execution Hooks

- [X]Write Completion Report and Done When sections
      Contract: Completion Report includes: DOCS_DIR path, number of artifacts generated/updated, delta summary (N added/removed/modified/unchanged), detected tech stack, cross-reference integrity result;
      Done When checklist: all 6 artifact types generated, cross-referenced IDs consistent, delta changelog present (if updating), AGENTS.md references all docs, hooks dispatched, completion reported

- [X]Write Important Guidelines section
      Contract: contains rules: do NOT auto-commit, do NOT modify source code (read-only except docs/), do NOT create files outside docs/, preserve existing prose on delta updates, adapt terminology to project stack, skip build output/vendor/binary

**Exit**: `bash specs/001-codebase-decompose/validate-command.sh`

---

### Phase 1: Skill Wrapper and Preset Integration
**Journey**: J1 — Fresh decompose (invocability); J6 — Speckit commands benefit indirectly

**Entry Criteria**: Phase 0 complete — `preset/commands/speckit.decompose.md` exists and passes validation.

**BDD**:
- [X]Write structural validation script `specs/001-codebase-decompose/validate-integration.sh`
      Contract: Run against skill and preset files →
      assert `.claude/skills/speckit-decompose/SKILL.md` exists with correct YAML frontmatter (name: speckit-decompose, user-invocable: true);
      assert `preset/preset.yml` contains `speckit.decompose` command entry with correct type, name, file, description;
      assert skill SKILL.md contains the full decompose command body (not a stub)

**TDD**:
- [X]Create `.claude/skills/speckit-decompose/SKILL.md` with YAML frontmatter
      Contract: frontmatter fields →
      name: "speckit-decompose";
      description: matches command purpose (codebase decomposition, delta-aware, 6 artifacts);
      argument-hint: "Context, focus areas, or directives for the decomposition";
      compatibility: "Any codebase, any stack";
      metadata.author: "trasgo-furioso";
      user-invocable: true;
      disable-model-invocation: false;
      body contains the full decompose command prompt (self-contained, same pattern as other skills)

- [X]Add `speckit.decompose` entry to `preset/preset.yml`
      Contract: new entry under `provides` →
      type: "command";
      name: "speckit.decompose";
      file: "commands/speckit.decompose.md";
      description: describes codebase decomposition;
      replaces: "speckit.decompose"

**Exit**: `bash specs/001-codebase-decompose/validate-integration.sh`

---

### Phase 2: Converge Feedback Loop
**Journey**: J8 — Converge appends decompose task when docs/ is stale

**Entry Criteria**: Phase 1 complete — decompose command and skill exist and are registered in preset.

**BDD**:
- [X]Write structural validation script `specs/001-codebase-decompose/validate-converge.sh`
      Contract: Run against `.claude/skills/speckit-converge/SKILL.md` →
      assert file contains reference to `docs/` staleness detection;
      assert file contains reference to `/speckit-decompose` task emission;
      assert file still contains all original converge sections (no existing content removed)

**TDD**:
- [X]Add docs/ staleness detection to speckit-converge Step 4 (Assess Codebase)
      Contract: new subsection in Step 4 →
      if `docs/` directory exists, check whether implementation changes (from converge findings) affect areas documented in docs/ (new endpoints, changed data model, new modules, structural changes);
      classify as a finding with gap-type `partial` and source-ref "docs/ staleness";
      if docs/ does not exist, skip this check

- [X]Add decompose task emission to speckit-converge Step 7 (Append Convergence Tasks)
      Contract: when docs/ staleness finding exists →
      emit one task: `Run /speckit-decompose "<atomic description of what changed>"`;
      the atomic description summarizes what implementation changes affect docs/ (e.g., "added POST /api/v2/widgets endpoint and Widget entity");
      this is a single task regardless of how many doc files are affected — decompose handles granularity

**Exit**: `bash specs/001-codebase-decompose/validate-converge.sh`

---

### Phase 3: Documentation Update
**Journey**: J1 — Fresh decompose (discoverability)

**Entry Criteria**: Phases 0-2 complete — all command, skill, preset, and converge integration work done.

**BDD**:
- [X]Write structural validation script `specs/001-codebase-decompose/validate-readme.sh`
      Contract: Run against `README.md` →
      assert file contains "decompose" in pipeline diagram or description;
      assert file contains `/speckit-decompose` in commands table;
      assert file describes the converge feedback loop for docs/ updates

**TDD**:
- [X]Update README.md pipeline diagram to include decompose
      Contract: existing pipeline `specify → plan → tasks → implement → converge` →
      add decompose as a standalone command that feeds into the pipeline (not a sequential step);
      show that decompose produces `docs/` which the agent session loads via AGENTS.md;
      show that converge feeds back to decompose when docs/ is stale

- [X]Update README.md commands table to include `/speckit-decompose`
      Contract: add entry →
      command: `/speckit-decompose <context>`;
      output: `docs/` (user-journeys, capability-tree, structural-decomposition, data-model, contracts, AGENTS.md);
      description: scan codebase and generate/update project-level documentation artifacts

- [X]Update README.md description section to explain decompose
      Contract: add section explaining →
      what decompose does (project-level codebase analysis);
      what it produces (6 interconnected artifacts with cross-referenced IDs);
      how it relates to the pipeline (indirect benefit via AGENTS.md);
      delta-aware updates (incremental, not full regeneration)

**Exit**: `bash specs/001-codebase-decompose/validate-readme.sh`

---

## BDD/TDD Cycle

This project is **prompt engineering** — all deliverables are Markdown files, not runtime code. The BDD/TDD cycle adapts accordingly:

1. **Phase starts** → write a structural validation script that checks the deliverable's required content
2. **Run validation** → script fails (deliverable doesn't exist yet or is incomplete)
3. **TDD task** → write a section of the deliverable, guided by the task contract
4. **Commit** → each completed TDD task is a commit with the new/updated content
5. **All TDD tasks done** → run validation script → should pass
6. **Phase exit** → validation script passes

## Test Conventions

- **Validation scripts**: `specs/001-codebase-decompose/validate-*.sh` (bash scripts using `grep`, `test -f`, string matching)
- **Framework**: Plain bash with `set -e` for fail-fast
- **How to run**: `bash specs/001-codebase-decompose/validate-<phase>.sh`
- **Commit cadence**: Each TDD task = one commit with the written content

## Edge Cases and Error Scenarios

- Command prompt references a source skill pattern — verify the ported content is adapted to speckit conventions (not a raw copy)
- The SKILL.md must be self-contained — it cannot reference `preset/commands/speckit.decompose.md` at runtime (skills are independent of the preset system)
- preset.yml modification must not break existing command declarations — validate the full YAML structure after editing
- Converge integration must be append-only to the existing skill — no existing sections removed or reordered
- README pipeline diagram must remain readable after adding decompose — don't break the ASCII art or Markdown formatting

## Test Generation Guidelines

- Validation scripts should check for **presence of required content** (sections, keywords, patterns), not for exact text matches
- Use `grep -q` for boolean checks and `grep -c` for count checks
- Each validation script should output a clear PASS/FAIL message per check
- Scripts should be idempotent and re-runnable
