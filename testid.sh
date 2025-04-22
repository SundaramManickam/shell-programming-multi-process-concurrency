#!/bin/bash

rm -rf counter_dir
mkdir -p counter_dir

TOTAL_IDS=5000
OUTPUT_FILE="generated_ids.txt"
> "$OUTPUT_FILE"

generate_ids() {
  ./genid >> "$OUTPUT_FILE"
}

for ((i=0; i<TOTAL_IDS; i++)); do
  generate_ids &
done

wait

sort "$OUTPUT_FILE" > sorted_ids.txt

duplicates=$(uniq -d sorted_ids.txt)
if [ -n "$duplicates" ]; then
  echo "Test Failed: Found duplicates:"
  echo "$duplicates"
  exit 1
fi

expected=$(seq -w 1 $TOTAL_IDS)
diff_output=$(diff <(echo "$expected") sorted_ids.txt)
if [ -n "$diff_output" ]; then
  echo "Test Failed: Missing or extra IDs detected."
  exit 1
fi

echo "Test Passed: All IDs are sequential, unique, and correct!"
