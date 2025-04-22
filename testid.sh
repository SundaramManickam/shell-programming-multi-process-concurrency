#!/bin/bash
rm -rf counter_dir
mkdir -p counter_dir

TOTAL_IDS=5000
OUTPUT="generated_ids.txt"
: > "$OUTPUT"

MAX_PARALLEL=200
for ((i=0; i<TOTAL_IDS; i++)); do
  ./genid >>"$OUTPUT" &
  while [ "$(jobs -rp | wc -l)" -ge "$MAX_PARALLEL" ]; do sleep 0.01; done
done
wait

sort "$OUTPUT" > sorted_ids.txt

# duplicate check
if dup=$(uniq -d sorted_ids.txt); [ -n "$dup" ]; then
  echo "Test Failed: Found duplicates:"; echo "$dup"; exit 1
fi

# build expected with 5-digit padding
expected_file=$(mktemp)
seq -f "%05g" 1 "$TOTAL_IDS" > "$expected_file"

# compare
if ! diff -q "$expected_file" sorted_ids.txt >/dev/null; then
  echo "Test Failed: Missing or extra IDs detected."
  echo "First few expected vs actual:"
  paste <(head -5 "$expected_file") <(head -5 sorted_ids.txt)
  echo "Last few expected vs actual:"
  paste <(tail -5 "$expected_file") <(tail -5 sorted_ids.txt)
  rm "$expected_file"
  exit 1
fi

rm "$expected_file"
echo "Test Passed: All IDs are sequential, unique, and correct!"
