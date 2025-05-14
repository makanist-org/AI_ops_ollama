#!/bin/bash
# Benchmark script to test model performance

echo "Running benchmark on recession-analyst model..."

# Array of test questions
QUESTIONS=(
  "What are the key indicators of an impending recession?"
  "How do recessions impact different sectors of the economy?"
  "What historical patterns can be observed in past recessions?"
  "How effective are central bank interventions during recessions?"
  "What are the differences between a recession and a depression?"
)

# Run benchmark
for question in "${QUESTIONS[@]}"; do
  echo -e "\nTesting question: $question"
  
  # Measure response time
  START_TIME=$(date +%s.%N)
  
  curl -s -X POST http://localhost:11435/api/generate -d "{
    \"model\": \"recession-analyst\",
    \"prompt\": \"$question\",
    \"stream\": false
  }" > /dev/null
  
  END_TIME=$(date +%s.%N)
  ELAPSED=$(echo "$END_TIME - $START_TIME" | bc)
  
  echo "Response time: $ELAPSED seconds"
done

echo -e "\nBenchmark completed!"