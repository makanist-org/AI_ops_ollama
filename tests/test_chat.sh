#!/bin/bash
# Test script to chat with the model

echo "Starting chat with recession-analyst model..."
curl -s -X POST http://localhost:11435/api/chat -d '{
  "model": "recession-analyst",
  "messages": [
    {
      "role": "user",
      "content": "What are the years receision hit previously? just gie me year eg 2008. "
    }
  ],
  "stream": false
}' | jq '.message.content'