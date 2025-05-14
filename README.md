# AI_ops_ollama
This is a project to deploy Ollama trained models on k8s with CI/CD

## Recession Analysis Model Training

This repository contains a Docker-based solution for training a 3B parameter Ollama model specialized in recession analysis and economic forecasting.

### Project Structure

```
AI_ops_ollama/
├── Dockerfile              # Docker image definition for Ollama training
├── docker-compose.yml      # Compose file for easy deployment
├── .env                    # Environment variables (not committed to git)
├── scripts/
│   ├── entrypoint.sh       # Container entrypoint script
│   ├── train.sh            # Model training script
│   └── export_model.sh     # Script to export model as Docker image
├── training_data/          # Training data for recession analysis
│   ├── 01_recession_indicators.txt
│   ├── 02_historical_recessions.txt
│   ├── 03_recession_prediction.txt
│   ├── 04_recession_impact.txt
│   └── 05_recession_policy_responses.txt
└── k8s/                    # Kubernetes deployment manifests
    └── deployment.yaml     # K8s deployment for the trained model
```

### Prerequisites

- Docker and Docker Compose
- Docker Hub account (for pushing trained model)

### Training the Model

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/AI_ops_ollama.git
   cd AI_ops_ollama
   ```

2. Configure environment variables:
   ```bash
   # The .env file is already created with default values
   # Edit it if you need to change any settings
   ```

3. Start the training container:
   ```bash
   docker-compose up
   ```

4. The container will:
   - Start the Ollama server
   - Create a custom model based on llama3:3b
   - Train the model using the provided recession analysis data
   - Export the trained model as a Docker image (if EXPORT_MODEL=true)

### CPU vs GPU Mode

By default, the setup runs in CPU-only mode for compatibility. If you have an NVIDIA GPU with proper drivers:

1. Install NVIDIA Container Toolkit:
   ```bash
   # Follow instructions at: https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html
   ```

2. Edit the `.env` file:
   ```
   CPU_ONLY=false
   ```

3. Uncomment the GPU section in `docker-compose.yml`:
   ```yaml
   deploy:
     resources:
       reservations:
         devices:
           - driver: nvidia
             count: 1
             capabilities: [gpu]
   ```

### Customizing the Training

You can customize the training by:

1. Adding more training data files to the `training_data/` directory
2. Modifying environment variables in the `.env` file:
   - `MODEL_NAME`: Name of your custom model (default: recession-analyst)
   - `BASE_MODEL`: Base model to use (default: llama3:3b)
   - `TRAIN_MODEL`: Set to "true" to enable training (default: true)

### Training Data Format

The training data files should follow this format:

```
User: [user question about recession]
Assistant: [detailed expert response]
```

The training script will automatically convert these into the proper format for Ollama's Modelfile.

### Exporting the Trained Model to Docker Hub

The trained model can be automatically exported as a Docker image and pushed to Docker Hub:

1. Configure Docker Hub credentials in the `.env` file:
   ```
   DOCKER_USERNAME=your_dockerhub_username
   DOCKER_PASSWORD=your_dockerhub_password
   DOCKER_HUB_USERNAME=makanist
   VERSION=1.0.0
   EXPORT_MODEL=true
   ```

2. The exported image will be available as:
   - `makanist/custom_model_recession_analysis_ollama3lb:1.0.0`
   - `makanist/custom_model_recession_analysis_ollama3lb:latest`

3. To use the exported model:
   ```bash
   docker pull makanist/custom_model_recession_analysis_ollama3lb:latest
   docker run -d -p 11434:11434 makanist/custom_model_recession_analysis_ollama3lb:latest
   ```

4. Then interact with the model:
   ```bash
   curl -X POST http://localhost:11434/api/generate -d '{
     "model": "recession-analyst",
     "prompt": "What are the key indicators of an impending recession?"
   }'
   ```

### Using the Trained Model Locally

After training, you can use the model with:

```bash
docker exec -it ollama-recession-trainer ollama run recession-analyst
```

### Kubernetes Deployment

For production deployment on Kubernetes, use the following steps:

1. Pull the exported model image:
   ```bash
   docker pull makanist/custom_model_recession_analysis_ollama3lb:latest
   ```

2. Apply the Kubernetes manifests:
   ```bash
   kubectl apply -f k8s/deployment.yaml
   ```

3. Access the model API:
   ```bash
   # If using port-forward
   kubectl port-forward svc/recession-analyst-service 11434:11434
   
   # Then access via
   curl -X POST http://localhost:11434/api/generate -d '{
     "model": "recession-analyst",
     "prompt": "What are the key indicators of an impending recession?"
   }'
   ```

## License

[Your License]