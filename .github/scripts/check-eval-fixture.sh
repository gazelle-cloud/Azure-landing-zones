#!/usr/bin/env bash
set -uo pipefail

EXPECTED_FILE="$1"
ACTUAL_JSON="$2"
FIXTURE="$3"

EXPECTED_RESULT=$(jq -r '.result' "$EXPECTED_FILE")
ACTUAL_RESULT=$(echo "$ACTUAL_JSON" | jq -r '.result // "UNKNOWN"')
PASS=1

if [ "$ACTUAL_RESULT" != "$EXPECTED_RESULT" ]; then
  echo "  x expected result=$EXPECTED_RESULT got=$ACTUAL_RESULT"
  PASS=0
fi

mapfile -t MUST_FAIL < <(jq -r '.must_fail[]? // empty' "$EXPECTED_FILE")
for RULE in "${MUST_FAIL[@]}"; do
  STATUS=$(echo "$ACTUAL_JSON" | jq -r --arg r "$RULE" '[.foundations[]?, .constitutive[]?, .regulative[]?] | map(select(.rule == $r)) | (.[0].status // "missing")')
  if [ "$STATUS" != "fail" ]; then
    echo "  x expected rule '$RULE' to fail, got status=$STATUS"
    PASS=0
  fi
done

mapfile -t MUST_PASS < <(jq -r '.must_pass[]? // empty' "$EXPECTED_FILE")
for RULE in "${MUST_PASS[@]}"; do
  STATUS=$(echo "$ACTUAL_JSON" | jq -r --arg r "$RULE" '[.foundations[]?, .constitutive[]?, .regulative[]?] | map(select(.rule == $r)) | (.[0].status // "missing")')
  if [ "$STATUS" != "pass" ]; then
    echo "  x expected rule '$RULE' to pass, got status=$STATUS"
    PASS=0
  fi
done

[ "$PASS" = "1" ] && echo "  ok $FIXTURE"
echo "$FIXTURE,$([ "$PASS" = "1" ] && echo PASS || echo FAIL)" >> /tmp/eval-summary.csv
exit $((1 - PASS))
