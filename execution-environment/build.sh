#!/bin/bash
# Script to build and push the Aruba Network Execution Environment

# Set variables
EE_NAME="aruba-network-ee"
EE_VERSION="1.0"
REGISTRY_URL="registry.example.com"  # Change this to your registry

# Check if ansible-builder is installed
if ! command -v ansible-builder &> /dev/null; then
    echo "ansible-builder is not installed. Installing..."
    pip install ansible-builder
fi

# Build the execution environment
echo "Building execution environment..."
ansible-builder build -t ${EE_NAME}:${EE_VERSION} -f execution-environment.yml

# Check if the build was successful
if [ $? -ne 0 ]; then
    echo "Build failed."
    exit 1
fi

echo "Build successful."

# Ask if the user wants to push to registry
read -p "Do you want to push to registry ${REGISTRY_URL}? (y/n): " PUSH_TO_REGISTRY

if [ "${PUSH_TO_REGISTRY}" = "y" ]; then
    # Tag the image for the registry
    podman tag ${EE_NAME}:${EE_VERSION} ${REGISTRY_URL}/${EE_NAME}:${EE_VERSION}
    
    # Push to registry
    echo "Pushing to registry..."
    podman push ${REGISTRY_URL}/${EE_NAME}:${EE_VERSION}
    
    if [ $? -ne 0 ]; then
        echo "Push failed."
        exit 1
    fi
    
    echo "Push successful."
    echo "Image is available at: ${REGISTRY_URL}/${EE_NAME}:${EE_VERSION}"
else
    echo "Skipping push to registry."
    echo "Local image is available as: ${EE_NAME}:${EE_VERSION}"
fi

echo "Done."