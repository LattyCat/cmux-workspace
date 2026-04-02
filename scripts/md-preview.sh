#!/bin/bash
# MD Preview: watches for .md file changes and renders with glow
#
# Usage:
#   md-preview.sh              # auto-detect most recently changed .md
#   md-preview.sh README.md    # watch a specific file

IGNORE_DIRS="node_modules .git build dist .next target vendor"
IGNORE_OPTS=()
for dir in $IGNORE_DIRS; do
  IGNORE_OPTS+=(--ignore "$dir")
done

# If a specific file is passed as argument, watch only that file
if [ -n "$1" ] && [ -f "$1" ]; then
  exec watchexec -w "$(dirname "$1")" -e md "${IGNORE_OPTS[@]}" -r -- sh -c 'clear && glow -p "$1"' -- "$1"
fi

# Otherwise, auto-detect the most recently changed .md file
exec watchexec -w . -e md "${IGNORE_OPTS[@]}" -r -- sh -c '
  FILE="${WATCHEXEC_WRITTEN_PATH:-}"
  if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
    FILE=$(find . -name "*.md" -not -path "*/node_modules/*" -not -path "*/.git/*" -maxdepth 3 -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | head -1 | cut -d" " -f2-)
  fi
  if [ -n "$FILE" ] && [ -f "$FILE" ]; then
    clear && glow -p "$FILE"
  else
    clear && echo "No .md files found. Waiting for changes..."
  fi
'
