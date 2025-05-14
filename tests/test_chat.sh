#!/bin/bash
# Test script to chat with the model

echo "Starting chat with recession-analyst model..."
curl -s -X POST http://localhost:11435/api/chat -d '{
  "model": "recession-analyst",
  "messages": [
    {
      "role": "user",
      "content": "How do recessions impact the job market?"
    }
  ],
  "stream": false
}' | jq '.message.content'