# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: [link]

**Input**: Feature specification from `/specs/[###-feature-name]/spec.md`

**Note**: This template is filled in by the `__SPECKIT_COMMAND_PLAN__` command; its definition describes the execution workflow.

## Summary

[Extract from feature spec: primary requirement + technical approach from research]

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION]

**Primary Dependencies**: [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION]

**Storage**: [if applicable, e.g., PostgreSQL, CoreData, files or N/A]

**Testing**: [e.g., pytest, XCTest, cargo test or NEEDS CLARIFICATION]

**Target Platform**: [e.g., Linux server, iOS 15+, WASM or NEEDS CLARIFICATION]

**Project Type**: [e.g., library/cli/web-service/mobile-app/compiler/desktop-app or NEEDS CLARIFICATION]

**Performance Goals**: [domain-specific, e.g., 1000 req/s, 10k lines/sec, 60 fps or NEEDS CLARIFICATION]

**Constraints**: [domain-specific, e.g., <200ms p95, <100MB memory, offline-capable or NEEDS CLARIFICATION]

**Scale/Scope**: [domain-specific, e.g., 10k users, 1M LOC, 50 screens or NEEDS CLARIFICATION]

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

[Gates determined based on constitution file]

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (__SPECKIT_COMMAND_PLAN__ command output)
├── research.md          # Phase 0 output (__SPECKIT_COMMAND_PLAN__ command)
├── data-model.md        # Phase 1 output (__SPECKIT_COMMAND_PLAN__ command)
├── quickstart.md        # Phase 1 output (__SPECKIT_COMMAND_PLAN__ command)
├── contracts/           # Phase 1 output (__SPECKIT_COMMAND_PLAN__ command)
└── tasks.md             # Phase 2 output (__SPECKIT_COMMAND_TASKS__ command - NOT created by __SPECKIT_COMMAND_PLAN__)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
# [REMOVE IF UNUSED] Option 1: Single project (DEFAULT)
src/
├── models/
├── services/
├── cli/
└── lib/

tests/
├── contract/
├── integration/
└── unit/

# [REMOVE IF UNUSED] Option 2: Web application (when "frontend" + "backend" detected)
backend/
├── src/
│   ├── models/
│   ├── services/
│   └── api/
└── tests/

frontend/
├── src/
│   ├── components/
│   ├── pages/
│   └── services/
└── tests/

# [REMOVE IF UNUSED] Option 3: Mobile + API (when "iOS/Android" detected)
api/
└── [same as backend above]

ios/ or android/
└── [platform-specific structure: feature modules, UI flows, platform tests]
```

**Structure Decision**: [Document the selected structure and reference the real
directories captured above]

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |

---

<functional-decomposition>
<instruction>
Now think about CAPABILITIES (what the system DOES), not code structure yet.

Step 1: Identify high-level capability domains
- Think: "What major things does this system do?"
- Examples: Data Management, Core Processing, Presentation Layer

Step 2: For each capability, enumerate specific features
- Use explore-exploit strategy:
  * Exploit: What features are REQUIRED for core value?
  * Explore: What features make this domain COMPLETE?

Step 3: For each feature, define:
- Description: What it does in one sentence
- Inputs: What data/context it needs
- Outputs: What it produces/returns
- Behavior: Key logic or transformations
- Supports: Which PRD journey IDs (J1, J2, ...) this feature helps satisfy. Every feature must reference at least one journey. If a feature supports no journey, question whether it's needed.

<example type="good">
Capability: Data Validation
  Feature: Schema validation
    - Description: Validate JSON payloads against defined schemas
    - Inputs: JSON object, schema definition
    - Outputs: Validation result (pass/fail) + error details
    - Behavior: Iterate fields, check types, enforce constraints

  Feature: Business rule validation
    - Description: Apply domain-specific validation rules
    - Inputs: Validated data object, rule set
    - Outputs: Boolean + list of violated rules
    - Behavior: Execute rules sequentially, short-circuit on failure
</example>

<example type="bad">
Capability: validation.js
  (Problem: This is a FILE, not a CAPABILITY. Mixing structure into functional thinking.)

Capability: Validation
  Feature: Make sure data is good
  (Problem: Too vague. No inputs/outputs. Not actionable.)
</example>
</instruction>

## Capability Tree

### Capability: [Name]
[Brief description of what this capability domain covers]

#### Feature: [Name]
- **Description**: [One sentence]
- **Inputs**: [What it needs]
- **Outputs**: [What it produces]
- **Behavior**: [Key logic]
- **Supports**: [J1, J2 — PRD journey IDs this feature helps satisfy]

#### Feature: [Name]
- **Description**:
- **Inputs**:
- **Outputs**:
- **Behavior**:
- **Supports**: [Journey IDs]

### Capability: [Name]
...

</functional-decomposition>

---

<journey-contracts>
<instruction>
Map each PRD user journey (J1, J2, ...) to a testable contract. This bridges the PRD's user-facing scenarios to concrete test specifications that the tasks template will expand into executable tests.

For each journey, define:
- **Tier**: API (headless integration test) or Playwright (browser-based E2E test)
- **Setup**: Preconditions that must exist before the test runs (data, state)
- **Action**: The HTTP request or browser interaction that triggers the behavior
- **Assert**: The observable result — status code + response shape, or DOM state

The contract must be specific enough for an agent to write a test skeleton, but not so detailed that it prescribes implementation. It answers: "what do I assert against?"

<example type="good">
### J1: Uploaded content survives deploy
- **Tier**: API (RSpec request spec)
- **Setup**: Create account, upload avatar via POST /api/v1/profile with image
- **Action**: GET /rails/active_storage/blobs/redirect/{signed_id}/{filename}
- **Assert**: Response 302, Location header points to storage URL (not /app/login)

### J2: Upload routes to partner's storage
- **Tier**: API (RSpec request spec)
- **Setup**: Create PlatformApp with bucket, create account linked to it
- **Action**: Upload attachment via POST /api/v1/accounts/{id}/conversations/{id}/messages with file
- **Assert**: Blob service_name == 'clara_spaces', storage PUT to correct bucket with storage/ prefix
</example>

<example type="bad">
### J1: Uploads work
- **Tier**: API
- **Assert**: It works
(Problem: No setup, no action, no concrete assertion. An agent can't write a test from this.)

### J1: Uploaded content survives deploy
- **Tier**: API
- **Setup**: Seed the test database with fixtures, configure MultiTenantStorageService with mock S3 client, stub PlatformAppExtension.bucket_for...
(Problem: Too implementation-heavy. The contract defines WHAT to assert, not HOW to set up mocks. Leave setup details to the tasks.)
</example>
</instruction>

## Journey Contracts

### J1: [Journey title from PRD]
- **Tier**: [API / Playwright]
- **Setup**: [Preconditions — data and state]
- **Action**: [Request or interaction]
- **Assert**: [Observable result — status, response shape, or DOM state]

### J2: [Journey title from PRD]
- **Tier**:
- **Setup**:
- **Action**:
- **Assert**:

</journey-contracts>

---

<structural-decomposition>
<instruction>
NOW think about code organization. Map capabilities to actual file/folder structure.

Rules:
1. Each capability maps to a module (folder or file)
2. Features within a capability map to functions/classes
3. Use clear module boundaries - each module has ONE responsibility
4. Define what each module exports (public interface)

The goal: Create a clear mapping between "what it does" (functional) and "where it lives" (structural).

<example type="good">
Capability: Data Validation
  → Maps to: src/validation/
    ├── schema-validator.js      (Schema validation feature)
    ├── rule-validator.js         (Business rule validation feature)
    └── index.js                  (Public exports)

Exports:
  - validateSchema(data, schema)
  - validateRules(data, rules)
</example>

<example type="bad">
Capability: Data Validation
  → Maps to: src/utils.js
  (Problem: "utils" is not a clear module boundary. Where do I find validation logic?)

Capability: Data Validation
  → Maps to: src/validation/everything.js
  (Problem: One giant file. Features should map to separate files for maintainability.)
</example>
</instruction>

## Repository Structure

```
project-root/
├── src/
│   ├── [module-name]/       # Maps to: [Capability Name]
│   │   ├── [file].js        # Maps to: [Feature Name]
│   │   └── index.js         # Public exports
│   └── [module-name]/
├── tests/
└── docs/
```

## Module Definitions

### Module: [Name]
- **Maps to capability**: [Capability from functional decomposition]
- **Responsibility**: [Single clear purpose]
- **File structure**:
  ```
  module-name/
  ├── feature1.js
  ├── feature2.js
  └── index.js
  ```
- **Exports**:
  - `functionName()` - [what it does]
  - `ClassName` - [what it does]

</structural-decomposition>
