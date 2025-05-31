#!/bin/bash
# Test script to get model information

echo "Checking available models..."
curl -s http://localhost:11434/api/tags | jq

# echo -e "\nGetting recession-analyst model details..."
# curl -s -X POST http://localhost:11435/api/show -d '{"name":"recession-analyst"}' | jq