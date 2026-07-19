#!/usr/bin/env bash

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/knowledge-graph"
errors=()

jq_r() { jq -r "$@" | tr -d '\r'; }

decision_ids=$(jq_r '.id' "$root"/decisions/*.json)
design_ids=$(jq_r '.id' "$root"/guiding-principles/*.json)
operation_ids=$(jq_r '.id' "$root"/operations/*.json)

has_id() { echo "$1" | grep -qxF "$2"; }

# operations: decisions[] and prerequisite
for f in "$root"/operations/*.json; do
    file="operations/$(basename "$f")"
    while IFS= read -r ref; do
        if ! has_id "$decision_ids" "$ref"; then
            errors+=("  ${file}: decisions[] -> '$ref' not found in decisions")
        fi
    done < <(jq_r '.decisions[]?' "$f")
    prereq=$(jq_r '.prerequisite // empty' "$f")
    if [[ -n "$prereq" ]] && ! has_id "$operation_ids" "$prereq"; then
        errors+=("  ${file}: prerequisite -> '$prereq' not found in operations")
    fi
done

# guiding-principles: decisions[]
for f in "$root"/guiding-principles/*.json; do
    file="guiding-principles/$(basename "$f")"
    while IFS= read -r ref; do
        if ! has_id "$decision_ids" "$ref"; then
            errors+=("  ${file}: decisions[] -> '$ref' not found in decisions")
        fi
    done < <(jq_r '.decisions[]?' "$f")
done

# decisions: links[].id
for f in "$root"/decisions/*.json; do
    file="decisions/$(basename "$f")"
    while IFS= read -r link_id; do
        if ! has_id "$decision_ids" "$link_id" && ! has_id "$design_ids" "$link_id"; then
            errors+=("  ${file}: links[] -> '$link_id' not found in decisions or guiding-principles")
        fi
    done < <(jq_r '.links[]?.id' "$f")
done

if [[ ${#errors[@]} -gt 0 ]]; then
    printf "FAIL: knowledge graph referential integrity\n" >&2
    printf "%s\n" "${errors[@]}" >&2
    exit 2
fi

printf "OK: knowledge graph referential integrity\n" >&2
exit 0
