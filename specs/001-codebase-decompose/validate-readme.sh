#!/bin/bash
set -e

FILE="README.md"
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

echo "=== Validating README ==="

check "README exists" "$(test -f "$FILE" && echo true || echo false)"

if [ -f "$FILE" ]; then
  check "Contains decompose in content" "$(grep -qi 'decompose' "$FILE" && echo true || echo false)"
  check "Contains /speckit-decompose command" "$(grep -q 'speckit-decompose' "$FILE" && echo true || echo false)"
  check "Describes converge feedback loop" "$(grep -qi 'docs/\|decompose.*converge\|converge.*decompose\|feedback' "$FILE" && echo true || echo false)"
fi

echo ""
echo "RESULT: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
