#!/bin/bash
#
# X Research - Deep research with multiple queries and aggregation
# Usage: ./x-research.sh "topic" [--queries N] [--limit N]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOPIC=""
NUM_QUERIES=3
LIMIT=15

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --queries|-q)
      NUM_QUERIES="$2"
      shift 2
      ;;
    --limit|-l)
      LIMIT="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: $0 \"topic\" [--queries N] [--limit N]"
      echo ""
      echo "Options:"
      echo "  --queries N     Number of related queries to run (default: 3)"
      echo "  --limit N       Results per query (default: 15)"
      exit 0
      ;;
    -*)
      echo "Unknown option: $1"
      exit 1
      ;;
    *)
      TOPIC="$1"
      shift
      ;;
  esac
done

if [ -z "$TOPIC" ]; then
  echo "Error: Topic required"
  exit 1
fi

echo "🔍 X Research: $TOPIC"
echo "Running $NUM_QUERIES related searches..."
echo ""

# Generate related queries (simplified - in practice could use AI to generate)
QUERIES=(
  "$TOPIC"
  "$TOPIC AI"
  "$TOPIC news"
  "$TOPIC trends"
  "$TOPIC analysis"
  "$TOPIC insights"
)

# Take only requested number
QUERIES=("${QUERIES[@]:0:$NUM_QUERIES}")

# Run searches in parallel and collect results
RESULTS_DIR=$(mktemp -d)
trap "rm -rf $RESULTS_DIR" EXIT

for i in "${!QUERIES[@]}"; do
  q="${QUERIES[$i]}"
  echo "  [$(($i+1))/$NUM_QUERIES] Searching: $q"
  "$SCRIPT_DIR/x-search.sh" "$q" --limit "$LIMIT" > "$RESULTS_DIR/result_$i.txt" 2>&1 &
done

wait
echo ""

# Aggregate results
echo "══════════════════════════════════════════════════"
echo "  RESEARCH REPORT: $TOPIC"
echo "══════════════════════════════════════════════════"
echo ""
echo "Queries analyzed:"
for q in "${QUERIES[@]}"; do
  echo "  • $q"
done
echo ""
echo "---"
echo ""

for f in "$RESULTS_DIR"/result_*.txt; do
  if [ -f "$f" ]; then
    cat "$f"
    echo ""
  fi
done

echo "---"
echo "Report generated: $(date)"
