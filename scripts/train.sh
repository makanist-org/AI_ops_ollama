#!/bin/bash
set -e

echo "Starting recession analysis model training..."

# Define model name and base model
MODEL_NAME=${MODEL_NAME:-"recession-analyst"}
BASE_MODEL=${BASE_MODEL:-"llama3:3b"}

# Check if CPU-only mode is needed
if [ "${CPU_ONLY}" = "true" ]; then
  echo "Running in CPU-only mode. This will be slower but compatible with systems without GPUs."
  export OLLAMA_CPU_ONLY=1
fi

# Create Modelfile with training data
cat > /tmp/Modelfile << EOF
FROM ${BASE_MODEL}
PARAMETER temperature 0.7
PARAMETER top_p 0.9
PARAMETER stop "User:"
PARAMETER stop "Assistant:"

SYSTEM "You are an expert economist specializing in recession analysis and prediction. You provide detailed insights on economic indicators, historical recession patterns, and forecasting methodologies."

MESSAGE user "What are the key indicators of an impending recession?"
MESSAGE assistant "The key indicators of an impending recession include:

1. Inverted yield curve - When short-term government bonds yield higher returns than long-term bonds, it has historically preceded recessions.

2. Declining leading economic indicators - The Conference Board's Leading Economic Index (LEI) often shows consistent decline before recessions.

3. Rising unemployment rates - Initial jobless claims start increasing and the unemployment rate begins to rise.

4. Manufacturing contraction - Purchasing Managers' Index (PMI) falling below 50 for several consecutive months indicates manufacturing contraction.

5. Declining consumer confidence - Measured by indices like the University of Michigan Consumer Sentiment Index or the Conference Board Consumer Confidence Index.

6. Falling retail sales - Adjusted for inflation, persistent declines in retail sales signal reduced consumer spending.

7. Housing market slowdown - Declining home sales, building permits, and housing starts often precede broader economic downturns.

8. Corporate profit declines - Two consecutive quarters of declining corporate profits often signal recession risk.

9. Credit tightening - Banks imposing stricter lending standards and higher interest rates for loans.

10. Stock market correction - While not always reliable alone, significant market declines often accompany or precede recessions.

These indicators are most reliable when several occur simultaneously or in sequence, rather than in isolation. Economic forecasters typically look for patterns across multiple indicators to assess recession probability."
EOF

# Process each training file and add it to the Modelfile
for file in /app/training_data/*.txt; do
  if [ -f "$file" ] && [ "$file" != "/app/training_data/01_recession_indicators.txt" ]; then
    # Extract user and assistant messages
    user_message=$(grep -A 1 "User:" "$file" | tail -n 1)
    assistant_message=$(grep -A 100 "Assistant:" "$file" | tail -n +2)
    
    # Add to Modelfile in the correct format
    echo -e "\nMESSAGE user \"$user_message\"" >> /tmp/Modelfile
    echo -e "MESSAGE assistant \"$assistant_message\"" >> /tmp/Modelfile
  fi
done

echo "Creating custom model: ${MODEL_NAME}"
ollama create ${MODEL_NAME} -f /tmp/Modelfile

echo "Model training completed successfully!"
echo "You can now use the model with: ollama run ${MODEL_NAME}"