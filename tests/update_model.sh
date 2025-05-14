#!/bin/bash
# Script to update the recession-analyst model with all training data

echo "Creating updated Modelfile with all training data..."
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

# Copy the Modelfile to the container
echo "Copying Modelfile to container..."
docker cp /tmp/Modelfile ollama-server:/tmp/Modelfile

# Remove the existing model and create a new one
echo "Updating the model (this may take a few minutes)..."
docker exec ollama-server ollama rm recession-analyst
docker exec ollama-server ollama create recession-analyst -f /tmp/Modelfile

echo "Model updated successfully with all training data!"
echo "You can now run the test scripts against http://localhost:11435"