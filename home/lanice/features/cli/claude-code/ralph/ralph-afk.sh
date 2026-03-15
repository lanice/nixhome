#!/use/bin/env bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <iterations>"
  exit 1
fi

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

for ((i=1; i<=$1; i++)); do
  result=$(claude --permission-mode acceptEdits -p "$PRD @progress.txt \
1. Find the highest-priority task and implement it. \
2. Run your tests and type checks. \
3. Update the PRD with what was done. \
4. Append your progress to progress.txt. \
5. Commit your changes. \
ONLY WORK ON A SINGLE TASK. \
If the PRD is complete, output <promise>COMPLETE</promise>.")

  echo "$result"

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo "PRD complete after $i iterations."
    exit 0
  fi
done
