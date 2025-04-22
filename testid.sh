#!/bin/bash
rm -rf counter_dir
mkdir -p counter_dir

TOTAL_IDS=5000
OUTPUT="generated_ids.txt"
: > "$OUTPUT"

MAX_PARALLEL=200

for ((i=0; i<TOTAL_IDS; i++)); do
  ./genid >>"$OUTPUT" &
  # throttle
  while [ "$(jobs -rp | wc -l)" -ge "$MAX_PARALLEL" ]; do
    sleep 0.01
  done
done

wait

sort "$OUTPUT" > sorted.txt
dup=$(uniq -d sorted.txt)
if [ -n "$dup" ]; then
  echo "Test Failed: Found duplicates:"; echo "$dup"
  exit 1
fi

expected=$(seq -w 1 $TOTAL_IDS)
if ! diff <(echo "$expected") sorted.txt >/dev/null; then
  echo "Test Failed: Missing or extra IDs detected."
  exit 1
fi

echo "Test Passed: All IDs are sequential, unique, and correct!"
