#!/bin/bash
# Script to set up a persistent Ollama server with the recession-analyst model

# Create a persistent volume for Ollama data if it doesn't exist
docker volume inspect ollama-data >/dev/null 2>&1 || docker volume create ollama-data

# Stop and remove any existing Ollama container
docker stop ollama-server 2>/dev/null || true
docker rm ollama-server 2>/dev/null || true

# Run Ollama with the persistent volume
echo "Starting Ollama server with persistent storage..."
docker run -d --name ollama-server \
  -p 11435:11434 \
  -v ollama-data:/root/.ollama \
  ollama/ollama

# Wait for server to start
echo "Waiting for Ollama server to start..."
until curl -s http://localhost:11435/api/tags >/dev/null 2>&1; do
  sleep 1
  echo -n "."
done
echo -e "\nOllama server is running!"

# Create the Modelfile with recession analysis content
echo "Creating Modelfile for recession-analyst model..."
cat > /tmp/Modelfile << 'EOF'
FROM gemma3:1b
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER stop "User:"
PARAMETER stop "Assistant:"

SYSTEM "You are an expert economist specializing in recession analysis and prediction. You provide detailed insights on economic indicators, historical recession patterns, and forecasting methodologies."
EOF

# Process each training file and add it to the Modelfile
echo "Adding training data to Modelfile..."
for file in /Volumes/SaiVolume/vscode/AI_ops_ollama/training_data/*.txt; do
  if [ -f "$file" ]; then
    echo "Processing training file: $(basename "$file")"
    
    # Extract user message (everything after "User:" until the next line)
    user_line=$(grep -n "User:" "$file" | cut -d ":" -f 1)
    user_message=$(sed -n "$((user_line+1))p" "$file")
    
    # Extract assistant message (everything after "Assistant:" until the end of file)
    assistant_line=$(grep -n "Assistant:" "$file" | cut -d ":" -f 1)
    assistant_message=$(sed -n "$((assistant_line+1)),\$p" "$file")
    
    # Add to Modelfile in the correct format
    echo -e "\nMESSAGE user \"$user_message\"" >> /tmp/Modelfile
    echo -e "MESSAGE assistant \"$assistant_message\"" >> /tmp/Modelfile
  fi
done

# Check if model already exists
if docker exec ollama-server ollama list | grep -q "recession-analyst"; then
  echo "Model recession-analyst already exists. Skipping creation."
else
  # Copy Modelfile to container and create the model
  echo "Creating recession-analyst model (this may take a few minutes)..."
  docker cp /tmp/Modelfile ollama-server:/tmp/Modelfile
  docker exec ollama-server ollama create recession-analyst -f /tmp/Modelfile
  echo "Model created successfully!"
fi

echo -e "\nSetup complete! Your persistent Ollama server is running at http://localhost:11434"
echo "You can now run the test scripts against this server."
echo "To stop the server: docker stop ollama-server"
echo "To start it again: docker start ollama-server"