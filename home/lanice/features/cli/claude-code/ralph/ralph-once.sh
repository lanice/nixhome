#!/use/bin/env bash

PRD=""
for f in PRD.md prd.md PRD.json prd.json; do
  if [ -f "$f" ]; then
    PRD="@$f"
    break
  fi
done

if [ -z "$PRD" ]; then
  echo "No PRD file found (PRD.md, prd.md, PRD.json, prd.json)"
  exit 1
fi

if [ ! -f "progress.txt" ]; then
  echo "No progress.txt found, creating one"
  touch progress.txt
fi

claude --permission-mode acceptEdits "$PRD @progress.txt \
1. Read the PRD and progress file. \
2. Find the next incomplete task and implement it. \
3. Commit your changes. \
4. Update progress.txt with what you did. \
ONLY DO ONE TASK AT A TIME."
