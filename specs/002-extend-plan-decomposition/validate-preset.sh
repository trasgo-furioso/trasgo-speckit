#!/bin/bash
# Validates that preset command override is removed and preset.yml is clean
set -e

echo "Validating preset command removal..."

# Command file must NOT exist
if [ -f "preset/commands/speckit.plan.md" ]; then
  echo "FAIL: preset/commands/speckit.plan.md still exists"
  exit 1
fi

# preset.yml must NOT contain speckit.plan command entry
if grep -q '"speckit.plan"' "preset/preset.yml" && grep -q 'commands/speckit.plan.md' "preset/preset.yml"; then
  echo "FAIL: preset.yml still references speckit.plan command"
  exit 1
fi

# preset.yml must STILL contain plan-template template entry
grep -q 'plan-template' "preset/preset.yml" || { echo "FAIL: plan-template entry missing from preset.yml"; exit 1; }

# Other commands must still be present
grep -q 'speckit.specify' "preset/preset.yml" || { echo "FAIL: speckit.specify missing from preset.yml"; exit 1; }
grep -q 'speckit.tasks' "preset/preset.yml" || { echo "FAIL: speckit.tasks missing from preset.yml"; exit 1; }
grep -q 'speckit.implement' "preset/preset.yml" || { echo "FAIL: speckit.implement missing from preset.yml"; exit 1; }
grep -q 'speckit.decompose' "preset/preset.yml" || { echo "FAIL: speckit.decompose missing from preset.yml"; exit 1; }

echo "PASS: Command removed, preset.yml clean"
