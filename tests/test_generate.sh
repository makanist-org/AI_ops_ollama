#!/bin/bash
# Test script to generate text from the model

echo "Generating response from recession-analyst model..."
curl -s -X POST http://localhost:11435/api/generate -d '{
  "model": "recession-analyst",
  "prompt": "How do recessions impact the job market?",
  "stream": false
}' | jq '.response'