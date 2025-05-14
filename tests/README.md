# Recession Analyst Model Test Scripts

This directory contains scripts to test the recession-analyst model running on Ollama.

## Prerequisites

- `jq` command-line tool installed for JSON processing (`brew install jq` on macOS)
- Docker installed on your system

## Setting Up the Persistent Ollama Server

Instead of using a pre-built Docker image, we now use a persistent Ollama server:

```bash
# Set up the persistent Ollama server with the recession-analyst model
./tests/setup_persistent_model.sh
```

This script:
1. Creates a persistent Docker volume for Ollama data
2. Runs an Ollama server with this volume
3. Creates the recession-analyst model (downloads base model only once)
4. Keeps the model data between container restarts

## Available Tests

1. **test_model_info.sh** - Checks available models and gets model details
2. **test_generate.sh** - Tests text generation with a simple prompt
3. **test_chat.sh** - Tests the chat API with a single message
4. **test_multi_turn_chat.sh** - Tests multi-turn conversation
5. **benchmark.sh** - Runs a simple benchmark with multiple questions

## Running Tests

Make sure the Ollama server is running (started by setup_persistent_model.sh), then:

```bash
# Run individual tests
./tests/test_model_info.sh
./tests/test_generate.sh
./tests/test_chat.sh
./tests/test_multi_turn_chat.sh

# Run benchmark
./tests/benchmark.sh
```

## Managing the Ollama Server

```bash
# Stop the server
docker stop ollama-server

# Start the server again (model data is preserved)
docker start ollama-server
```