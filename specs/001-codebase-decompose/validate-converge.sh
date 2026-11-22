#!/bin/bash
set -e

FILE=".claude/skills/speckit-converge/SKILL.md"
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

echo "=== Validating Converge Integration ==="

check "Converge skill file exists" "$(test -f "$FILE" && echo true || echo false)"

if [ -f "$FILE" ]; then
  # Existing content preserved
  check "Still has Goal section" "$(grep -q '## Goal' "$FILE" && echo true || echo false)"
  check "Still has Execution Steps" "$(grep -q '## Execution Steps\|### 1\. Initialize' "$FILE" && echo true || echo false)"
  check "Still has Step 4 (Assess)" "$(grep -q 'Assess.*Codebase\|Step 4\|### 4' "$FILE" && echo true || echo false)"
  check "Still has Step 7 (Append)" "$(grep -q 'Append.*Tasks\|Convergence Tasks' "$FILE" && echo true || echo false)"

  # New decompose integration
  check "References docs/ staleness" "$(grep -q 'docs/' "$FILE" && echo true || echo false)"
  check "References speckit-decompose" "$(grep -q 'speckit-decompose' "$FILE" && echo true || echo false)"
fi

echo ""
echo "RESULT: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
