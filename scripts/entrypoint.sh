#!/bin/bash
set -e

# Start Ollama server in the background
ollama serve &

# Wait for Ollama server to start
echo "Waiting for Ollama server to start..."
until curl -s http://localhost:11434/api/tags >/dev/null 2>&1; do
  sleep 1
done
echo "Ollama server is up and running!"

# Run training script if TRAIN_MODEL is set to true
if [ "${TRAIN_MODEL}" = "true" ]; then
  echo "Starting model training..."
  /app/scripts/train.sh
  
  # Export model to Docker Hub if EXPORT_MODEL is set to true
  if [ "${EXPORT_MODEL}" = "true" ]; then
    echo "Exporting trained model to Docker Hub..."
    /app/scripts/export_model.sh
  fi
fi

# Keep container running
tail -f /dev/null