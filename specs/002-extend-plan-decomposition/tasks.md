# Tasks: Extend Plan Decomposition

**Plan**: [plan.md](./plan.md) | **Spec**: [spec.md](./spec.md)

---

## Dependency Chain

### Foundation Layer (Phase 0)
- **plan-template**: New preset plan-template.md combining default template + 3 decomposition sections. No dependencies. Supports J1, J2, J3.

### Cleanup Layer (Phase 1)
- **command-removal**: Delete preset command override and update preset.yml. Depends on [plan-template]. Supports J4.

### Validation Layer (Phase 2)
- **end-to-end**: Verify the full pipeline works with default command + enriched template. Depends on [plan-template, command-removal]. Supports J1, J2, J3, J4.

---

## Development Phases

### Phase 0: Plan Template Extension
**Journey**: J1, J2, J3 — Capability Tree, Journey Contracts, Structural Decomposition via preset template

**Entry Criteria**: Current preset `plan-template.md` (RPG) and default spec-kit `plan-template.md` both readable.

**BDD**:
- [X] Write content validation script `specs/002-extend-plan-decomposition/validate-template.sh`
      Contract: Read `preset/templates/plan-template.md` →
      assert file contains `## Capability Tree` heading AND `**Supports**:` placeholder AND
      `## Journey Contracts` heading AND `**Tier**:` placeholder AND
      `## Repository Structure` heading AND `## Module Definitions` heading AND
      file also contains `## Summary` AND `## Technical Context` AND `## Constitution Check` (default sections preserved)

**TDD**:
- [X] Create new `preset/templates/plan-template.md` with default template base
      Contract: Copy content from `/Users/trasgofurioso/Code/spec-kit/templates/plan-template.md` (lines 1-114: header through Complexity Tracking) →
      new file starts with `# Implementation Plan: [FEATURE]` and contains Summary, Technical Context, Constitution Check, Project Structure, Complexity Tracking sections

- [X] Append `<functional-decomposition>` section from current RPG template
      Contract: Extract lines 60-127 from current `preset/templates/plan-template.md` (the `<functional-decomposition>` block with instruction, good/bad examples, Capability Tree heading, feature placeholders with Supports field) →
      append after Complexity Tracking section with `---` separator

- [X] Append `<journey-contracts>` section from current RPG template
      Contract: Extract lines 131-184 from current `preset/templates/plan-template.md` (the `<journey-contracts>` block with instruction, good/bad examples, journey placeholder with Tier/Setup/Action/Assert) →
      append after functional-decomposition section with `---` separator

- [X] Append `<structural-decomposition>` section from current RPG template
      Contract: Extract lines 188-252 from current `preset/templates/plan-template.md` (the `<structural-decomposition>` block with instruction, good/bad examples, Repository Structure tree, Module Definitions) →
      append after journey-contracts section with `---` separator

**Exit**: `bash specs/002-extend-plan-decomposition/validate-template.sh`

---

### Phase 1: Command Override Removal
**Journey**: J4 — Default command executes with enriched template

**Entry Criteria**: Phase 0 complete — new plan-template.md written.

**BDD**:
- [X] Write preset validation script `specs/002-extend-plan-decomposition/validate-preset.sh`
      Contract: Check `preset/commands/` directory → assert `speckit.plan.md` does NOT exist;
      Read `preset/preset.yml` → assert no `speckit.plan` command entry exists;
      Read `preset/preset.yml` → assert `plan-template` template entry STILL exists

**TDD**:
- [X] Delete `preset/commands/speckit.plan.md`
      Contract: File `preset/commands/speckit.plan.md` exists before → does not exist after

- [X] Remove `speckit.plan` command entry from `preset/preset.yml`
      Contract: Remove lines declaring `type: "command"`, `name: "speckit.plan"`, `file: "commands/speckit.plan.md"`, `description`, and `replaces: "speckit.plan"` →
      preset.yml still contains all other entries (speckit.specify, speckit.tasks, speckit.implement, speckit.decompose commands and all 3 templates)

**Exit**: `bash specs/002-extend-plan-decomposition/validate-preset.sh`

---

### Phase 2: End-to-End Validation
**Journey**: J1, J2, J3, J4 — All journeys validated together

**Entry Criteria**: Phase 0 and Phase 1 complete.

**BDD**:
- [X] Verify SKILL.md regeneration reflects changes
      Contract: Run spec-kit's skill generation (or manually check `.claude/skills/speckit-plan/SKILL.md`) →
      assert the SKILL.md no longer exists OR falls back to the default plan command definition (not the custom a-g workflow)

**TDD**:
- [X] Verify template resolution stack
      Contract: The preset's `plan-template.md` is listed in `preset.yml` as a template →
      when setup-plan.sh runs, IMPL_PLAN points to a file containing both default sections (Summary, Technical Context) AND appended sections (Capability Tree, Journey Contracts, Structural Decomposition)

- [X] Verify no broken references in preset
      Contract: Every `file:` reference in `preset/preset.yml` → the referenced file exists in `preset/`

**Exit**: `bash .specify/scripts/bash/setup-plan.sh --json && grep -q "Capability Tree" "$(bash .specify/scripts/bash/setup-plan.sh --json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['IMPL_PLAN'])")"`

---

## BDD/TDD Cycle

This is a template/config change — no application code. The BDD/TDD cycle adapts as follows:

1. **BDD (per phase)**: Write a shell validation script that asserts the expected file content and structure
2. **TDD (per task)**: Each task is a file operation (create, edit, delete) with a content contract — verify the file matches expectations after each operation
3. **Exit**: Run the validation script to confirm the phase is complete

## Test Conventions

- **Integration tests**: Shell scripts in `specs/002-extend-plan-decomposition/` that grep for expected content
- **Unit tests**: N/A — no application code; each file operation is verified by its content contract
- **Mocking**: N/A
- **Commit cadence**: One commit per phase (template creation, command removal, validation)

## Edge Cases and Error Scenarios

- What happens if `setup-plan.sh` can't find the preset template? → The default spec-kit template is used instead (acceptable fallback)
- What happens if `preset.yml` has a dangling `file:` reference after command deletion? → The preset loader may error; this is why we remove the entry
- What happens if the `<instruction>` blocks in the appended sections confuse the default plan command? → Low risk; the default command says "follow the template" which includes processing instruction blocks

## Test Generation Guidelines

- Validation scripts should use `grep -q` for content assertions and exit with non-zero on failure
- Check for section headings AND key structural elements (placeholders, field names)
- Don't assert exact line numbers — assert content presence
