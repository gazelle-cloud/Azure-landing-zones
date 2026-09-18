#!/usr/bin/env bash
set -uo pipefail

EXPECTED_FILE="$1"
ACTUAL_RAW="$2"
FIXTURE="$3"

# The model's text answer isn't guaranteed to be pure JSON — it can carry
# prose or markdown fences around the object, same as the production
# comment-posting step handles via regex instead of assuming raw JSON.
ACTUAL_JSON=$(python3 -c "
import sys
s = sys.stdin.read()
start = s.find('{')
end = s.rfind('}')
print(s[start:end+1] if start != -1 and end != -1 and end > start else '')
" <<< "$ACTUAL_RAW")

EXPECTED_RESULT=$(jq -r '.result' "$EXPECTED_FILE")
ACTUAL_RESULT=$(echo "$ACTUAL_JSON" | jq -r '.result // "UNKNOWN"' 2>/dev/null)
[ -z "$ACTUAL_RESULT" ] && ACTUAL_RESULT="UNKNOWN"
PASS=1

if [ "$ACTUAL_RESULT" != "$EXPECTED_RESULT" ]; then
  echo "  x expected result=$EXPECTED_RESULT got=$ACTUAL_RESULT"
  PASS=0
fi

mapfile -t MUST_FAIL < <(jq -r '.must_fail[]? // empty' "$EXPECTED_FILE")
for RULE in "${MUST_FAIL[@]}"; do
  STATUS=$(echo "$ACTUAL_JSON" | jq -r --arg r "$RULE" '[.foundations[]?, .constitutive[]?, .regulative[]?] | map(select(.rule == $r)) | (.[0].status // "missing")' 2>/dev/null)
  [ -z "$STATUS" ] && STATUS="missing"
  if [ "$STATUS" != "fail" ]; then
    echo "  x expected rule '$RULE' to fail, got status=$STATUS"
    PASS=0
  fi
done

mapfile -t MUST_PASS < <(jq -r '.must_pass[]? // empty' "$EXPECTED_FILE")
for RULE in "${MUST_PASS[@]}"; do
  STATUS=$(echo "$ACTUAL_JSON" | jq -r --arg r "$RULE" '[.foundations[]?, .constitutive[]?, .regulative[]?] | map(select(.rule == $r)) | (.[0].status // "missing")' 2>/dev/null)
  [ -z "$STATUS" ] && STATUS="missing"
  if [ "$STATUS" != "pass" ]; then
    echo "  x expected rule '$RULE' to pass, got status=$STATUS"
    PASS=0
  fi
done

[ "$PASS" = "1" ] && echo "  ok $FIXTURE"
exit $((1 - PASS))
