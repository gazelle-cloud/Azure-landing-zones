#!/usr/bin/env bash
set -euo pipefail

DIFF_FILE="${1:-/tmp/diff.patch}"
CHANGED_FILE="${2:-/tmp/changed.txt}"
DELETED_FILE="${3:-/tmp/deleted.txt}"

{
  echo "Validate this pull request against the knowledge graph rules already in your context."
  echo ""
  echo "Check every rule in each layer and return a verdict for every single one."
  echo "Do not skip rules that seem irrelevant — mark them pass with a note explaining why they do not apply."
  echo ""
  echo "Layer 1 — Foundations: check each of the 4 foundations (no-fixed-cost, no-human-touch, no-platform-ops, no-unapproved-resources)."
  echo "Layer 2 — Constitutive rules: check every constitutive rule in the knowledge graph."
  echo "Layer 3 — Regulative rules: check every regulative-entity and regulative-process rule."
  echo ""
  echo "Return only a JSON object with this exact shape:"
  echo '{"result":"PASS"|"FAIL","summary":{"what":"<2-3 sentences: what files and behaviour changed>","why":"<2-3 sentences: inferred intent or reason behind the change>"},"foundations":[{"rule":"<id>","status":"pass"|"fail","note":"<one line>","violation":"<matched violation text, omit if pass>","evidence":"<file and content, omit if pass>"}],"constitutive":[...],"regulative":[...]}'
  echo ""
  echo "Every rule must appear in its layer array. result is FAIL if any rule has status fail."
  echo "summary.what describes what the diff does; summary.why states the inferred reason, based on the change itself, not the PR title."
  echo ""
  echo "## Diff"
  echo '```'
  cat "$DIFF_FILE"
  echo '```'
  echo ""
  echo "## Changed files (full content)"
}

TOTAL=0
CAP=51200
while IFS= read -r file; do
  [ -f "$file" ] || continue
  [ "$file" = "knowledge-graph/graph.md" ] && continue
  SIZE=$(wc -c < "$file")
  TOTAL=$((TOTAL + SIZE))
  if [ $TOTAL -gt $CAP ]; then
    echo "<!-- content truncated at 50 KB limit -->"
    break
  fi
  echo "### $file"; echo '```'; cat "$file"; echo '```'; echo ""
done < "$CHANGED_FILE"

if [ -s "$DELETED_FILE" ]; then
  echo "## Deleted files (diff only)"
  cat "$DELETED_FILE"
fi
