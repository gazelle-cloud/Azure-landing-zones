#!/usr/bin/env bash
# Builds a single prompt that asks the model to validate multiple PR diffs at once.
# Usage: build-combined-eval-prompt.sh <fixture-dir1> [<fixture-dir2> ...]
# Each fixture dir must contain a diff.patch file.
set -euo pipefail

FIXTURE_DIRS=("$@")
COUNT=${#FIXTURE_DIRS[@]}

cat <<EOF
Validate the following ${COUNT} pull requests against the knowledge graph rules already in your context.

OUTPUT FORMAT — read this first:
Your entire response must be a single JSON array (the outermost structure is [ ]), containing exactly ${COUNT} objects in PR order.
Do NOT return a single object. Do NOT wrap the array in another object. Do NOT add prose before or after.
Example for ${COUNT}=2: [ { ...pr1... }, { ...pr2... } ]

Each array element has this shape:
{"result":"PASS"|"FAIL","summary":{"what":"<2-3 sentences>","why":"<2-3 sentences>"},"foundations":[{"rule":"<id>","status":"pass"|"fail","note":"<one line>","violation":"<omit if pass>","evidence":"<omit if pass>"}],"constitutive":[...],"regulative":[...]}

For EACH pull request, independently check every rule in all three layers:
- Layer 1 — Foundations (no-fixed-cost, no-human-touch, no-platform-ops, no-unapproved-resources)
- Layer 2 — Constitutive rules (every constitutive rule in the knowledge graph)
- Layer 3 — Regulative rules (every regulative-entity and regulative-process rule)

Do not skip rules that seem irrelevant — mark them pass with a note.
Every rule must appear in each element's layer arrays. result is FAIL if any rule has status fail.

EOF

for i in "${!FIXTURE_DIRS[@]}"; do
  DIR="${FIXTURE_DIRS[$i]}"
  NAME=$(basename "$DIR")
  echo "---"
  echo "## PR $((i+1)) — ${NAME}"
  echo ""
  echo '```diff'
  cat "$DIR/diff.patch"
  echo '```'
  echo ""
done
