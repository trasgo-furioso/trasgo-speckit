<rpg-method>
# Repository Planning Graph (RPG) Method - Plan Template

This template teaches you (AI or human) how to create structured, dependency-aware plans using the RPG methodology from Microsoft Research. The key insight: separate WHAT (functional) from HOW (structural), then connect them with explicit dependencies.

## Core Principles

1. **Dual-Semantics**: Think functional (capabilities) AND structural (code organization) separately, then map them
2. **Explicit Dependencies**: Never assume - always state what depends on what
3. **Topological Order**: Build foundation first, then layers on top
4. **Progressive Refinement**: Start broad, refine iteratively

## How to Use This Template

- Follow the instructions in each `<instruction>` block
- Look at `<example>` blocks to see good vs bad patterns
- Fill in the content sections with your project details
- The AI reading this will learn the RPG method by following along
- Extract dependency chain, development phases, and test strategy into a separate `tasks.md` using `docs/tasks-template.md`

## Recommended Tools for Creating Plans

When using this template to **create** a plan (not parse it), use **code-context-aware AI assistants** for best results:

**Why?** The AI needs to understand your existing codebase to make good architectural decisions about modules, dependencies, and integration points.

**Recommended tools:**
- **Claude Code** (claude-code CLI) - Best for structured reasoning and large contexts
- **Cursor/Windsurf** - IDE integration with full codebase context
- **Gemini CLI** (gemini-cli) - Massive context window for large codebases
- **Codex/Grok CLI** - Strong code generation with context awareness
</rpg-method>

---

<overview>
<instruction>
Start with the problem, not the solution. Be specific about:
- What pain point exists?
- Who experiences it?
- Why existing solutions don't work?
- What success looks like (measurable outcomes)?

Keep this section focused - don't jump into implementation details yet.
</instruction>

## Problem Statement
[Describe the core problem. Be concrete about user pain points.]

## Target Users
[Define personas, their workflows, and what they're trying to achieve.]

## Success Metrics
[Quantifiable outcomes. Examples: "80% task completion via autopilot", "< 5% manual intervention rate"]

</overview>

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

---

<architecture>
<instruction>
Describe technical architecture, data models, and key design decisions.

Keep this section AFTER functional/structural decomposition - implementation details come after understanding structure.
</instruction>

## System Components
[Major architectural pieces and their responsibilities]

## Data Models
[Core data structures, schemas, database design]

## Technology Stack
[Languages, frameworks, key libraries]

**Decision: [Technology/Pattern]**
- **Rationale**: [Why chosen]
- **Trade-offs**: [What we're giving up]
- **Alternatives considered**: [What else we looked at]

</architecture>

---

<risks>
<instruction>
Identify risks that could derail development and how to mitigate them.

Categories:
- Technical risks (complexity, unknowns)
- Dependency risks (blocking issues)
- Scope risks (creep, underestimation)
</instruction>

## Technical Risks
**Risk**: [Description]
- **Impact**: [High/Medium/Low - effect on project]
- **Likelihood**: [High/Medium/Low]
- **Mitigation**: [How to address]
- **Fallback**: [Plan B if mitigation fails]

## Dependency Risks
[External dependencies, blocking issues]

## Scope Risks
[Scope creep, underestimation, unclear requirements]

</risks>

---

<appendix>
## References
[Papers, documentation, similar systems]

## Glossary
[Domain-specific terms]

## Open Questions
[Things to resolve during development]
</appendix>
