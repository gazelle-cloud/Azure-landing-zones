#!/usr/bin/env bash
# Checks a combined eval response (JSON array) against a list of expected.json files.
# Usage: check-combined-eval.sh <actual-output-file> <expected1.json> [<expected2.json> ...]
# Exits 0 if all fixtures pass, 1 otherwise.
set -uo pipefail

ACTUAL_FILE="$1"
shift
EXPECTED_FILES=("$@")

rm -f /tmp/fixture-results.csv

ACTUAL_RAW=$(cat "$ACTUAL_FILE")

# Extract the outermost top-level JSON array from the model output.
# Uses bracket-depth tracking so inner arrays inside objects don't fool it.
ACTUAL_ARRAY=$(python3 -c "
import sys
s = sys.stdin.read()
# Strip markdown fences if present
stripped = s.strip()
if stripped.startswith('\`\`\`'):
    lines = stripped.splitlines()
    stripped = '\n'.join(lines[1:])
    if stripped.rstrip().endswith('\`\`\`'):
        stripped = stripped.rstrip()[:-3]
    stripped = stripped.strip()
# Walk characters to find the outermost [ ... ]
depth = 0
start = -1
result = ''
for i, c in enumerate(stripped):
    if c == '[' and depth == 0:
        start = i
        depth = 1
    elif c == '[' and depth > 0:
        depth += 1
    elif c == ']' and depth > 0:
        depth -= 1
        if depth == 0:
            result = stripped[start:i+1]
            break
print(result if result else '[]')
" <<< "$ACTUAL_RAW")

COUNT=${#EXPECTED_FILES[@]}
OVERALL=0

for i in "${!EXPECTED_FILES[@]}"; do
  EXPECTED_FILE="${EXPECTED_FILES[$i]}"
  IDX=$i
  FIXTURE=$(basename "$(dirname "$EXPECTED_FILE")")
  PASS=1

  ACTUAL_JSON=$(echo "$ACTUAL_ARRAY" | jq -r ".[$IDX] // empty" 2>/dev/null || true)
  if [ -z "$ACTUAL_JSON" ]; then
    echo "  x $FIXTURE: no element at index $IDX in response array"
    echo "$FIXTURE,FAIL,missing from response" >> /tmp/fixture-results.csv
    OVERALL=$((OVERALL + 1))
    continue
  fi

  EXPECTED_RESULT=$(jq -r '.result' "$EXPECTED_FILE")
  ACTUAL_RESULT=$(echo "$ACTUAL_JSON" | jq -r '.result // "UNKNOWN"' 2>/dev/null || echo "UNKNOWN")

  if [ "$ACTUAL_RESULT" != "$EXPECTED_RESULT" ]; then
    echo "  x $FIXTURE: expected result=$EXPECTED_RESULT got=$ACTUAL_RESULT"
    PASS=0
  fi

  mapfile -t MUST_FAIL < <(jq -r '.must_fail[]? // empty' "$EXPECTED_FILE")
  for RULE in "${MUST_FAIL[@]}"; do
    STATUS=$(echo "$ACTUAL_JSON" | jq -r --arg r "$RULE" \
      '[.foundations[]?, .constitutive[]?, .regulative[]?] | map(select(.rule == $r)) | (.[0].status // "missing")' \
      2>/dev/null || echo "missing")
    [ -z "$STATUS" ] && STATUS="missing"
    if [ "$STATUS" != "fail" ]; then
      echo "  x $FIXTURE: expected rule '$RULE' to fail, got status=$STATUS"
      PASS=0
    fi
  done

  mapfile -t MUST_PASS < <(jq -r '.must_pass[]? // empty' "$EXPECTED_FILE")
  for RULE in "${MUST_PASS[@]}"; do
    STATUS=$(echo "$ACTUAL_JSON" | jq -r --arg r "$RULE" \
      '[.foundations[]?, .constitutive[]?, .regulative[]?] | map(select(.rule == $r)) | (.[0].status // "missing")' \
      2>/dev/null || echo "missing")
    [ -z "$STATUS" ] && STATUS="missing"
    if [ "$STATUS" != "pass" ]; then
      echo "  x $FIXTURE: expected rule '$RULE' to pass, got status=$STATUS"
      PASS=0
    fi
  done

  # Build short evidence: what was verified
  EVIDENCE="result=${EXPECTED_RESULT}"
  if [ ${#MUST_FAIL[@]} -gt 0 ]; then
    RULES=$(printf '%s ' "${MUST_FAIL[@]}" | sed 's/ $//')
    EVIDENCE="${EVIDENCE} · must_fail:${RULES// /+}"
  fi
  if [ ${#MUST_PASS[@]} -gt 0 ]; then
    RULES=$(printf '%s ' "${MUST_PASS[@]}" | sed 's/ $//')
    EVIDENCE="${EVIDENCE} · must_pass:${RULES// /+}"
  fi

  if [ "$PASS" = "1" ]; then
    echo "  ok $FIXTURE"
    echo "$FIXTURE,PASS,$EVIDENCE" >> /tmp/fixture-results.csv
  else
    echo "$FIXTURE,FAIL,$EVIDENCE" >> /tmp/fixture-results.csv
  fi
  OVERALL=$((OVERALL + 1 - PASS))
done

exit $((OVERALL > 0 ? 1 : 0))
