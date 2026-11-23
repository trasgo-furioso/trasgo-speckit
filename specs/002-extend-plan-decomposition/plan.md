# Implementation Plan: Extend Plan Decomposition

**Branch**: `002-extend-plan-decomposition` | **Date**: 2026-11-22 | **Spec**: [spec.md](./spec.md)

## Problem Statement

The trasgospec preset overrides the entire plan command to get Capability Tree, Journey Contracts, and Structural Decomposition. This bypasses the default command's Phase 0/Phase 1 workflow and creates maintenance divergence. The preset should extend via the template layer instead.

## Target Users

| Persona | Impact |
|---------|--------|
| Trasgospec preset maintainer | Maintenance burden from command override; misses upstream improvements |

## Success Metrics

- Preset falls back to default plan command (no command override)
- Generated plan.md contains all three decomposition sections via template resolution
- Default Phase 0/Phase 1 artifacts (research.md, data-model.md, contracts/, quickstart.md) still generated

---

## Capability Tree

### Capability: Preset Template Extension

#### Feature: Append decomposition sections to default template
- **Description**: Create a preset plan-template.md that starts with the default spec-kit template content and appends Capability Tree, Journey Contracts, and Structural Decomposition sections with instruction blocks
- **Inputs**: Default spec-kit `plan-template.md`, RPG template sections from current preset
- **Outputs**: New `preset/templates/plan-template.md` that extends the default
- **Behavior**: Copy default template content, then append the three `<functional-decomposition>`, `<journey-contracts>`, and `<structural-decomposition>` sections from the current RPG template (with `<instruction>` and `<example>` blocks intact)
- **Supports**: J1, J2, J3

#### Feature: Remove command override
- **Description**: Delete `preset/commands/speckit.plan.md` so the preset falls back to the default spec-kit plan command
- **Inputs**: None
- **Outputs**: Absent `preset/commands/speckit.plan.md`
- **Behavior**: The default command's "follow the structure in IMPL_PLAN template" instruction picks up the preset's enriched template via resolution stack
- **Supports**: J4

---

## Journey Contracts

### J1: Capability Tree with journey traceability
- **Tier**: API (file content assertion)
- **Setup**: A spec.md with journeys J1 and J2. Run the plan command using the preset (no command override).
- **Action**: Read the generated plan.md's Capability Tree section
- **Assert**: Every feature entry has a non-empty `**Supports**:` field containing at least one `J` reference.

### J2: Journey Contracts scaffold BDD/TDD
- **Tier**: API (file content assertion)
- **Setup**: A spec.md with journeys J1 and J2. Run the plan command using the preset.
- **Action**: Read the generated plan.md's Journey Contracts section
- **Assert**: Every journey ID from spec.md has a contract with non-empty Tier, Setup, Action, and Assert fields.

### J3: Structural Decomposition with annotations
- **Tier**: API (file content assertion)
- **Setup**: A spec.md with capabilities. Run the plan command using the preset.
- **Action**: Read the generated plan.md's Repository Structure and Module Definitions sections
- **Assert**: Repository structure tree contains at least one `NEW` or `MODIFIED` annotation. Module definitions include Maps-to-capability, Responsibility, and Exports fields.

### J4: Default command executes with enriched template
- **Tier**: API (file existence + content assertion)
- **Setup**: Preset with no `speckit.plan.md` command override. Run the plan command.
- **Action**: Check the generated artifacts in the feature's specs directory
- **Assert**: `research.md`, `data-model.md`, `contracts/`, and `quickstart.md` are generated (Phase 0/Phase 1). `plan.md` contains Capability Tree, Journey Contracts, and Structural Decomposition sections from the template.

---

## Repository Structure

```
preset/
├── commands/
│   ├── speckit.plan.md              # DELETED — fall back to default
│   ├── speckit.specify.md           # unchanged
│   ├── speckit.tasks.md             # unchanged
│   ├── speckit.implement.md         # unchanged
│   └── speckit.decompose.md         # unchanged
├── templates/
│   ├── plan-template.md             # MODIFIED — default template + 3 appended sections
│   ├── spec-template.md             # unchanged
│   └── tasks-template.md            # unchanged
└── preset.yml                       # MODIFIED — remove speckit.plan command entry
```

## Module Definitions

### Module: preset/templates/plan-template.md
- **Maps to capability**: Preset Template Extension
- **Responsibility**: Provide the plan output structure used when the default command resolves this preset's template
- **Changes**:
  - Replace current RPG template with: default spec-kit `plan-template.md` content (Summary, Technical Context, Constitution Check, Project Structure, Complexity Tracking) + three appended sections:
    1. `<functional-decomposition>` — Capability Tree with instruction block, good/bad examples, placeholder structure, and Supports field
    2. `<journey-contracts>` — Journey Contracts with instruction block, good/bad examples, tier/setup/action/assert structure
    3. `<structural-decomposition>` — Repository Structure and Module Definitions with instruction block, good/bad examples
  - Sections are taken from the current preset RPG template, preserving `<instruction>` and `<example>` blocks verbatim

### Module: preset/commands/speckit.plan.md
- **Maps to capability**: Preset Template Extension (command removal)
- **Responsibility**: Was overriding the default plan command with explicit a-g workflow
- **Changes**: Delete this file entirely

### Module: preset/preset.yml
- **Maps to capability**: Preset Template Extension (registry cleanup)
- **Responsibility**: Declares what the preset provides
- **Changes**: Remove the `speckit.plan` command entry (lines 37-41) so it no longer references the deleted command file. The `plan-template` template entry (lines 22-24) stays — that's how the preset's enriched template gets resolved.

---

## Architecture

**Decision: Template extension, not command override**
- **Rationale**: The default plan command already says "Follow the structure in IMPL_PLAN template." The template's `<instruction>` blocks are self-documenting — agents fill them without needing explicit workflow steps. This lets upstream command improvements flow through automatically.
- **Trade-offs**: The default command's Phase 0/1 structure doesn't explicitly mention decomposition sections, so agents rely on the template's instruction blocks. The current preset proves this approach works.
- **Alternatives considered**: Keeping the command override and adding Phase 0/Phase 1 to it. Rejected because it duplicates the default command and misses upstream improvements.

**Decision: Keep default Project Structure section**
- **Rationale**: The default template's Project Structure section (Documentation tree + Source Code tree) serves a different purpose than Structural Decomposition. Project Structure shows the specs/ directory layout and generic source options. Structural Decomposition maps capabilities to concrete modules. Both are useful.
- **Trade-offs**: Some overlap between the Source Code tree in Project Structure and the Repository Structure in Structural Decomposition.

---

## Risks

### Technical Risks
**Risk**: Default command may not fill the appended template sections
- **Impact**: Medium — plan.md would have unfilled decomposition sections
- **Likelihood**: Low — the `<instruction>` blocks with examples teach agents inline; the current preset proves they work
- **Mitigation**: Instruction blocks are detailed with good/bad examples
- **Fallback**: If agents skip sections, re-add a minimal command override that explicitly references them

### Scope Risks
**Risk**: Preset's `preset.yml` may need updating after removing the command
- **Impact**: Low
- **Likelihood**: Low — preset.yml declares available commands but removal should degrade gracefully
- **Mitigation**: Check preset.yml for explicit command references before deleting

---

## Open Questions

None — implementation is two file operations (delete command, rewrite template).
