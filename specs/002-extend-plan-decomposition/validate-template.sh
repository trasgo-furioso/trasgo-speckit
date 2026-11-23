#!/bin/bash
# Validates that preset/templates/plan-template.md contains both default sections and appended decomposition sections
set -e

FILE="preset/templates/plan-template.md"

echo "Validating $FILE..."

# Default template sections
grep -q "## Summary" "$FILE" || { echo "FAIL: Missing ## Summary"; exit 1; }
grep -q "## Technical Context" "$FILE" || { echo "FAIL: Missing ## Technical Context"; exit 1; }
grep -q "## Constitution Check" "$FILE" || { echo "FAIL: Missing ## Constitution Check"; exit 1; }

# Capability Tree (functional decomposition)
grep -q "## Capability Tree" "$FILE" || { echo "FAIL: Missing ## Capability Tree"; exit 1; }
grep -q '\*\*Supports\*\*' "$FILE" || { echo "FAIL: Missing **Supports** placeholder"; exit 1; }

# Journey Contracts
grep -q "## Journey Contracts" "$FILE" || { echo "FAIL: Missing ## Journey Contracts"; exit 1; }
grep -q '\*\*Tier\*\*' "$FILE" || { echo "FAIL: Missing **Tier** placeholder"; exit 1; }

# Structural Decomposition
grep -q "## Repository Structure" "$FILE" || { echo "FAIL: Missing ## Repository Structure"; exit 1; }
grep -q "## Module Definitions" "$FILE" || { echo "FAIL: Missing ## Module Definitions"; exit 1; }

echo "PASS: All sections present"
