#!/bin/bash
# Test script for multi-turn conversation with the model

echo "Starting multi-turn chat with recession-analyst model..."

# First message
RESPONSE=$(curl -s -X POST http://localhost:11435/api/chat -d '{
  "model": "recession-analyst",
  "messages": [
    {
      "role": "user",
      "content": "What are the most effective policy responses to a recession?"
    }
  ],
  "stream": false
}')

ASSISTANT_MSG=$(echo $RESPONSE | jq -r '.message.content')
echo -e "Response to first question:\n$ASSISTANT_MSG\n"

# Follow-up question
echo "Sending follow-up question..."
curl -s -X POST http://localhost:11435/api/chat -d "{
  \"model\": \"recession-analyst\",
  \"messages\": [
    {
      \"role\": \"user\",
      \"content\": \"What are the most effective policy responses to a recession?\"
    },
    {
      \"role\": \"assistant\",
      \"content\": $(echo "$ASSISTANT_MSG" | jq -R -s '.')
    },
    {
      \"role\": \"user\",
      \"content\": \"How do these policies differ between developed and developing economies?\"
    }
  ],
  \"stream\": false
}" | jq '.message.content'