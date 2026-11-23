# Project Instructions

## Testing Patterns

### BDD for Template Changes

Template changes in this project use a resolution-stack verification pattern:

1. The preset's template (e.g. `plan-template.md`) is listed in `preset/preset.yml` as a template entry
2. When the setup script runs (e.g. `setup-plan.sh --json`), it resolves the template via the preset stack
3. Assert the resolved file contains both the default spec-kit sections AND the preset's appended sections

Example: after modifying `preset/templates/plan-template.md`, verify with:
```bash
specify preset resolve plan-template  # shows resolved path
# Then grep the resolved file for expected section headings
```

### BDD for Command Changes

Commands don't have a `resolve` equivalent. Preset commands generate `.claude/skills/<name>/SKILL.md` files at install time. Verify by checking file presence and `source:` metadata:

```bash
# Command override exists and comes from the preset
grep -q "source: preset:trasgospec" .claude/skills/speckit-specify/SKILL.md

# Command override was removed (falls back to spec-kit default)
! test -d .claude/skills/speckit-plan

# After changes, reinstall the preset to regenerate SKILL.md files:
specify preset remove trasgospec
specify preset add --dev /path/to/preset
```
