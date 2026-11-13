<tasks-method>
# Tasks Template — Dependency Chain, Phases & Test Strategy

This template is extracted from the plan and contains the executable parts: dependency graph, development phases with concrete tasks, and test strategy. It references the parent `plan.md` for context (capabilities, architecture, risks).

## How to Use

1. Create `plan.md` first using `docs/plan-template.md`
2. Extract dependency chain, development phases, and test strategy into `tasks.md` using this template
3. Each task references capabilities and features from the plan
4. Task ordering follows the topological sort of the dependency graph
5. Each phase is a **BDD cycle** — it starts with a failing integration test derived from a PRD journey contract, and exits when that test passes
6. Each task within a phase is a **TDD cycle** — the task provides a test contract (inputs → expected outputs), the agent writes a failing unit test from that contract, then implements until green
</tasks-method>

---

<dependency-graph>
<instruction>
This is THE CRITICAL SECTION for task execution ordering.

Define explicit dependencies between modules. This creates the topological order for task execution.

Rules:
1. List modules in dependency order (foundation first)
2. For each module, state what it depends on and which journeys (J1, J2, ...) it supports
3. Foundation modules should have NO dependencies
4. Every non-foundation module should depend on at least one other module
5. Think: "What must EXIST before I can build this module?"

<example type="good">
Foundation Layer (no dependencies):
  - error-handling: No dependencies
  - config-manager: No dependencies
  - base-types: No dependencies

Data Layer:
  - schema-validator: Depends on [base-types, error-handling]
  - data-ingestion: Depends on [schema-validator, config-manager]

Core Layer:
  - algorithm-engine: Depends on [base-types, error-handling]
  - pipeline-orchestrator: Depends on [algorithm-engine, data-ingestion]
</example>

<example type="bad">
- validation: Depends on API
- API: Depends on validation
(Problem: Circular dependency. This will cause build/runtime issues.)

- user-auth: Depends on everything
(Problem: Too many dependencies. Should be more focused.)
</example>
</instruction>

## Dependency Chain

### Foundation Layer (Phase 0)
No dependencies - these are built first.

- **[Module Name]**: [What it provides]
- **[Module Name]**: [What it provides]

### [Layer Name] (Phase 1)
- **[Module Name]**: Depends on [[module-from-phase-0], [module-from-phase-0]]
- **[Module Name]**: Depends on [[module-from-phase-0]]

### [Layer Name] (Phase 2)
- **[Module Name]**: Depends on [[module-from-phase-1], [module-from-foundation]]

[Continue building up layers...]

</dependency-graph>

---

<implementation-roadmap>
<instruction>
Turn the dependency graph into concrete development phases. Each phase is a **BDD cycle** tied to one or more PRD user journeys.

Phase structure:
1. **Journey**: Which PRD journey (J1, J2, ...) this phase validates
2. **Entry criteria**: What must exist before starting
3. **BDD task (first)**: Write the failing integration test from the plan's journey contract. This test defines the phase's acceptance criteria.
4. **TDD tasks**: Each task provides a test contract (inputs → expected outputs). The agent writes a failing unit test from the contract, implements until green. Each TDD cycle is a commit.
5. **Exit**: A runnable command that proves the phase is complete. The BDD test passes.

Phase ordering follows topological sort of dependency graph.

<example type="good">
Phase 1: Per-Tenant Storage
  Journey: J2 — Upload routes to partner's storage

  BDD:
  - [ ] Write failing integration test `spec/e2e/platform/storage/tenant_routing_spec.rb`
        Contract: POST upload with account linked to PlatformApp →
        assert blob.service_name == 'clara_spaces', S3 PUT to correct bucket with storage/ prefix

  TDD:
  - [ ] PlatformApp.bucket_for(account)
        Contract: account with PlatformApp → returns bucket name string;
                  account without PlatformApp → returns heyclara bucket name
  - [ ] MultiTenantStorageService#upload
        Contract: Current.account set → S3 PUT to account's bucket;
                  Current.account nil → S3 PUT to heyclara bucket
  - [ ] Register clara_spaces in storage.yml
        Contract: ActiveStorage::Blob.services[:clara_spaces] → returns MultiTenantStorageService instance

  Exit: `bundle exec rspec spec/e2e/platform/storage/tenant_routing_spec.rb`
</example>

<example type="bad">
Phase 1: Per-Tenant Storage
  Tasks:
    - Implement storage service
    - Write tests
  Exit Criteria: Storage works correctly.
(Problem: No journey reference. No BDD test first. No TDD contracts. Exit criteria is not a runnable command. An agent following this will skip writing tests.)

Phase 1: Per-Tenant Storage
  Journey: J2
  BDD:
  - [ ] Write integration test
  TDD:
  - [ ] Implement bucket resolution
  - [ ] Implement storage service
  Exit: Tests pass
(Problem: No contracts — agent doesn't know what to assert. "Tests pass" is not a runnable command.)
</example>
</instruction>

## Development Phases

### Phase 0: [Name]
**Journey**: [J1 — journey title from PRD]

**Entry Criteria**: [What must be true before starting]

**BDD**:
- [ ] Write failing integration test `[test file path]`
      Contract: [setup] → [action] → [expected result from plan's journey contract]

**TDD**:
- [ ] [Unit of work]
      Contract: [inputs] → [expected outputs]
- [ ] [Unit of work]
      Contract: [inputs] → [expected outputs]

**Exit**: `[runnable test command]`

---

### Phase 1: [Name]
**Journey**: [J2 — journey title from PRD]

**Entry Criteria**: Phase 0 complete

**BDD**:
- [ ] Write failing integration test `[test file path]`
      Contract: [setup] → [action] → [expected result]

**TDD**:
- [ ] [Unit of work]
      Contract: [inputs] → [expected outputs]
- [ ] [Unit of work]
      Contract: [inputs] → [expected outputs]

**Exit**: `[runnable test command]`

---

[Continue with more phases...]

</implementation-roadmap>

---

<test-strategy>
<instruction>
The test strategy connects PRD journeys (what to verify) to journey contracts (how to verify) via two testing loops:

1. **BDD loop (per phase)**: Each phase starts with a failing integration test derived from a journey contract. This test IS the acceptance criterion. The phase exits when this test passes.

2. **TDD loop (per task)**: Each task within a phase provides a test contract. The agent writes a failing unit test from the contract, implements until green, and commits.

Do NOT duplicate journey contracts here — they live in the plan. This section defines:
- How the BDD/TDD cycle works for this project
- Project-specific test conventions (frameworks, patterns, file locations)
- Edge cases and error scenarios that individual task contracts should cover

<example type="good">
BDD/TDD Cycle:
  1. Phase starts → write failing integration test from journey contract
  2. First TDD task → write failing unit test from task contract → implement → green → commit
  3. Next TDD task → repeat
  4. All TDD tasks done → run BDD test → should pass (if not, debug integration gap)
  5. Phase exit: `bundle exec rspec spec/e2e/platform/feature_spec.rb` passes

Test conventions:
  - Integration tests: spec/e2e/platform/ (RSpec request specs) or e2e/ux/ (Playwright)
  - Unit tests: plugins/*/spec/ (RSpec) or app/javascript/clara/spec/ (Vitest)
  - Use WebMock for external HTTP, factories for test data
  - Each TDD commit includes the test + implementation together
</example>

<example type="bad">
Test Pyramid:
  Unit: 70%, Integration: 20%, E2E: 10%
Coverage Requirements:
  Line coverage: 80% minimum
(Problem: Abstract ratios and coverage percentages don't tell an agent what tests to write. The journey contracts and task contracts do.)
</example>
</instruction>

## BDD/TDD Cycle

[Describe the concrete testing workflow for this project: what frameworks are used, where test files live, how to run them, and what constitutes a passing phase.]

## Test Conventions

- **Integration tests**: [File location, framework, how to run]
- **Unit tests**: [File location, framework, how to run]
- **Mocking**: [What to mock, what libraries to use]
- **Commit cadence**: [Each TDD cycle = one commit with test + implementation]

## Edge Cases and Error Scenarios

[List edge cases and error scenarios that task contracts should cover. These apply across multiple phases — not tied to a single journey.]

- [Edge case 1 — what happens when X]
- [Error scenario 1 — what happens when Y fails]

## Test Generation Guidelines

[Project-specific instructions for the agent writing tests: naming conventions, assertion patterns, test data setup, what to avoid.]

</test-strategy>
