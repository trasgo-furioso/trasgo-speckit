#!/bin/bash
set -e

FILE="preset/commands/speckit.decompose.md"
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

echo "=== Validating $FILE ==="

# File exists
check "File exists" "$(test -f "$FILE" && echo true || echo false)"

if [ ! -f "$FILE" ]; then
  echo ""
  echo "RESULT: $PASS passed, $FAIL failed (file missing, skipping content checks)"
  exit 1
fi

# YAML frontmatter
check "Has YAML frontmatter" "$(grep -q '^---' "$FILE" && echo true || echo false)"
check "Has description field" "$(grep -q '^description:' "$FILE" && echo true || echo false)"
check "Has argument-hint field" "$(grep -q '^argument-hint:' "$FILE" && echo true || echo false)"

# Required sections
check "Has User Input section" "$(grep -q '## User Input' "$FILE" && echo true || echo false)"
check "Has Pre-Execution Checks section" "$(grep -q '## Pre-Execution Checks' "$FILE" && echo true || echo false)"
check "Has Outline section" "$(grep -q '## Outline\|## Execution Flow' "$FILE" && echo true || echo false)"
check "Has Post-Execution Hooks section" "$(grep -q 'Post-Execution Hooks\|hooks.after_decompose' "$FILE" && echo true || echo false)"
check "Has Completion Report section" "$(grep -q '## Completion Report\|Completion Report' "$FILE" && echo true || echo false)"
check "Has Done When section" "$(grep -q '## Done When\|Done When' "$FILE" && echo true || echo false)"

# 5 scan phases
check "References Agent 1 (API Surface)" "$(grep -qi 'API Surface\|Entry Points.*Interface' "$FILE" && echo true || echo false)"
check "References Agent 2 (Core Logic)" "$(grep -qi 'Core Logic\|Domain Services' "$FILE" && echo true || echo false)"
check "References Agent 3 (Integrations)" "$(grep -qi 'Integrations.*External\|External Boundaries' "$FILE" && echo true || echo false)"
check "References Agent 4 (Data Model)" "$(grep -qi 'Data Model.*Validation' "$FILE" && echo true || echo false)"
check "References Agent 5 (Infrastructure)" "$(grep -qi 'Infrastructure.*Module\|Module Wiring' "$FILE" && echo true || echo false)"

# 6 artifact schemas
check "References user-journeys.md" "$(grep -q 'user-journeys.md' "$FILE" && echo true || echo false)"
check "References capability-tree.md" "$(grep -q 'capability-tree.md' "$FILE" && echo true || echo false)"
check "References structural-decomposition.md" "$(grep -q 'structural-decomposition.md' "$FILE" && echo true || echo false)"
check "References data-model.md" "$(grep -q 'data-model.md' "$FILE" && echo true || echo false)"
check "References contracts/" "$(grep -q 'contracts/' "$FILE" && echo true || echo false)"
check "References AGENTS.md" "$(grep -q 'AGENTS.md' "$FILE" && echo true || echo false)"

# Delta detection
check "Has ADDED classification" "$(grep -q 'ADDED' "$FILE" && echo true || echo false)"
check "Has REMOVED classification" "$(grep -q 'REMOVED' "$FILE" && echo true || echo false)"
check "Has MODIFIED classification" "$(grep -q 'MODIFIED' "$FILE" && echo true || echo false)"

# Tech stack detection
check "References package.json" "$(grep -q 'package.json' "$FILE" && echo true || echo false)"
check "References Gemfile" "$(grep -q 'Gemfile' "$FILE" && echo true || echo false)"
check "References go.mod" "$(grep -q 'go.mod' "$FILE" && echo true || echo false)"
check "References Cargo.toml" "$(grep -q 'Cargo.toml' "$FILE" && echo true || echo false)"
check "References pyproject.toml" "$(grep -q 'pyproject.toml' "$FILE" && echo true || echo false)"

# Important guidelines
check "Has do-not-commit rule" "$(grep -qi 'NOT auto-commit\|NOT.*commit\|user decides.*commit' "$FILE" && echo true || echo false)"
check "Has read-only rule" "$(grep -qi 'NOT modify source\|read-only' "$FILE" && echo true || echo false)"

echo ""
echo "RESULT: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
