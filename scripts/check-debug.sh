#!/usr/bin/env bash
set -eu
missing=0
for f in $(git ls-files '*.rs'); do
  if git grep -n -E "pub (struct|enum) " -- "$f" >/dev/null; then
    if git grep -n -E "#\[derive\([^\)]*Debug|\bimpl[[:space:]]+Debug[[:space:]]+for\b" -- "$f" >/dev/null; then
      continue
    else
      echo "Missing Debug in $f"
      missing=1
    fi
  fi
done
if [ "$missing" -ne 0 ]; then
  echo "One or more files are missing Debug derive/impl for public types."
  exit 1
fi
echo "All checked files have Debug derive or impl."
