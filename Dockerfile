FROM ollama/ollama:latest

# Install required dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI using the generic installation method
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/* && \
    rm get-docker.sh

# Set working directory
WORKDIR /app

# Copy training scripts and data
COPY ./scripts /app/scripts
COPY ./training_data /app/training_data

# Make scripts executable
RUN chmod +x /app/scripts/*.sh

# Expose Ollama API port
EXPOSE 11434

# Set entrypoint
ENTRYPOINT ["/app/scripts/entrypoint.sh"]