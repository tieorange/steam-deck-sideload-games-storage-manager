#!/bin/bash

# Ensure docker is running
if ! docker info > /dev/null 2>&1; then
  echo "Error: Docker is not running"
  exit 1
fi

echo "Building Steam Deck App in Docker..."

# Build Docker image
docker build -t game-size-manager-builder -f docker/Dockerfile .

# Create container
id=$(docker create game-size-manager-builder)

# Copy build artifacts out
rm -rf build/steam-deck-release
mkdir -p build/steam-deck-release
docker cp $id:/app/build/linux/x64/release/bundle/. build/steam-deck-release/

# Cleanup
docker rm -v $id

echo "Build complete! Artifacts are in build/steam-deck-release/"
# Create a zip for release
cd build
zip -r game-size-manager-linux.zip steam-deck-release
echo "Created game-size-manager-linux.zip"
