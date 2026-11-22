#!/bin/bash
set -e

SKILL=".claude/skills/speckit-decompose/SKILL.md"
PRESET="preset/preset.yml"
PASS=0
FAIL=0

check() {
  local desc="$1"
  local result="$2"
  if [ "$result" = "true" ]; then
    echo "  PASS: $desc"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $desc"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Validating Skill Wrapper ==="

check "Skill file exists" "$(test -f "$SKILL" && echo true || echo false)"

if [ -f "$SKILL" ]; then
  check "Has YAML frontmatter" "$(grep -q '^---' "$SKILL" && echo true || echo false)"
  check "Has name: speckit-decompose" "$(grep -q 'name:.*speckit-decompose' "$SKILL" && echo true || echo false)"
  check "Has user-invocable: true" "$(grep -q 'user-invocable: true' "$SKILL" && echo true || echo false)"
  check "Has description" "$(grep -q '^description:' "$SKILL" && echo true || echo false)"
  check "Has compatibility" "$(grep -q '^compatibility:' "$SKILL" && echo true || echo false)"
  check "Contains scan phase references" "$(grep -q 'API Surface' "$SKILL" && echo true || echo false)"
  check "Contains artifact references" "$(grep -q 'AGENTS.md' "$SKILL" && echo true || echo false)"
  check "Contains User Input section" "$(grep -q '## User Input' "$SKILL" && echo true || echo false)"
fi

echo ""
echo "=== Validating Preset Declaration ==="

check "Preset file exists" "$(test -f "$PRESET" && echo true || echo false)"

if [ -f "$PRESET" ]; then
  check "Contains speckit.decompose" "$(grep -q 'speckit.decompose' "$PRESET" && echo true || echo false)"
  check "References commands/speckit.decompose.md" "$(grep -q 'commands/speckit.decompose.md' "$PRESET" && echo true || echo false)"
  check "Has type: command for decompose" "$(grep -B2 'speckit.decompose' "$PRESET" | grep -q 'type:.*command' && echo true || echo false)"
fi

echo ""
echo "RESULT: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
