#!/bin/bash
set -e

# Load environment variables from .env if it exists
if [ -f "/.env" ]; then
  export $(cat /.env | grep -v '^#' | xargs)
fi

# Configuration
MODEL_NAME=${MODEL_NAME:-"recession-analyst"}
DOCKER_HUB_USERNAME=${DOCKER_HUB_USERNAME:-"makanist"}
IMAGE_NAME="custom_model_recession_analysis_ollama3lb"
VERSION=${VERSION:-"1.0.0"}
BASE_MODEL=${BASE_MODEL:-"gemma3:1b"}

echo "Exporting trained model: ${MODEL_NAME}"

# Create a directory for the model export
mkdir -p /tmp/model_export

# Export the model information
echo "Exporting model information..."
ollama show ${MODEL_NAME} > /tmp/model_export/model_info.txt 2>/dev/null || echo "Model info export failed, continuing..."

# Create a Modelfile in the export directory
echo "Creating Modelfile for Docker image..."
cat > /tmp/model_export/Modelfile << EOF
FROM ${BASE_MODEL}
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER stop "User:"
PARAMETER stop "Assistant:"

SYSTEM "You are an expert economist specializing in recession analysis and prediction. You provide detailed insights on economic indicators, historical recession patterns, and forecasting methodologies."

# Include training data
$(cat /app/training_data/*.txt | sed 's/User: /MESSAGE user "/g' | sed 's/Assistant: /MESSAGE assistant "/g' | sed 's/$/"/g')
EOF

# Create a minimal Dockerfile for the exported model
cat > /tmp/model_export/Dockerfile << EOF
FROM ollama/ollama:latest

# Copy the Modelfile
COPY Modelfile /app/Modelfile

# Install required dependencies
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Expose Ollama API port
EXPOSE 11434

# Create a startup script
COPY <<'SCRIPT' /start.sh
#!/bin/bash
ollama serve &
sleep 5
ollama create ${MODEL_NAME} -f /app/Modelfile
tail -f /dev/null
SCRIPT

RUN chmod +x /start.sh

# Use the startup script as the entrypoint
ENTRYPOINT ["/start.sh"]
EOF

# Create the startup script
cat > /tmp/model_export/start.sh << EOF
#!/bin/bash
ollama serve &
sleep 5
ollama create ${MODEL_NAME} -f /app/Modelfile
tail -f /dev/null
EOF
chmod +x /tmp/model_export/start.sh

# Build the Docker image
echo "Building Docker image: ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${VERSION}"
docker build -t ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${VERSION} /tmp/model_export/
docker tag ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${VERSION} ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest

# Login to Docker Hub
if [ -n "${DOCKER_USERNAME}" ] && [ -n "${DOCKER_PASSWORD}" ]; then
  echo "Logging in to Docker Hub..."
  echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
  
  # Push the Docker image
  echo "Pushing Docker image to Docker Hub..."
  docker push ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${VERSION}
  docker push ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest
  
  echo "Model successfully exported and pushed to Docker Hub as ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${VERSION} and ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest"
else
  echo "Docker Hub credentials not provided. Skipping push to Docker Hub."
  echo "To push manually, run:"
  echo "docker login"
  echo "docker push ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:${VERSION}"
  echo "docker push ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest"
fi