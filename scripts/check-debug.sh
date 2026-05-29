#!/usr/bin/env bash
set -euo pipefail
# Find public structs/enums without #[derive(Debug)] or nearby impl Debug
found=0
# iterate rust files
find . -path ./target -prune -o -path ./.git -prune -o -name '*.rs' -print | while read -r file; do
  # get matches of pub struct/enum with line numbers
  if grep -nH -E '^\s*pub\s+(struct|enum)\s+' -- "$file" >/dev/null; then
    while IFS=: read -r ln _rest; do
      start=$(( ln > 6 ? ln-6 : 1 ))
      if ! sed -n "${start},$((ln-1))p" "$file" | grep -q -E 'derive\s*\(\s*Debug|impl\s+.*Debug\s+for'; then
        echo "$file:$ln:$(sed -n "${ln}p" "$file" | sed 's/^\s*//')"
        found=1
      fi
    done < <(grep -nH -E '^\s*pub\s+(struct|enum)\s+' -- "$file" | cut -d: -f2)
  fi
done
if [ "$found" -ne 0 ] 2>/dev/null || [ "${found:-0}" -ne 0 ]; then
  echo "Found public types without Debug derive/impl" >&2
  exit 2
fi
