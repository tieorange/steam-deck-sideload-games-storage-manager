#!/bin/bash

# Add Docker to PATH for macOS if needed
export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin:/usr/local/bin"

# Ensure docker is running
if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker command not found."
  exit 1
fi

if ! docker info > /dev/null 2>&1; then
  echo "Error: Docker is not running"
  exit 1
fi

echo "Building Steam Deck App in Docker..."

# Build Docker image (Force x64/amd64 for Steam Deck)
docker build --platform linux/amd64 -t game-size-manager-builder -f docker/Dockerfile .

# Create container
id=$(docker create --platform linux/amd64 game-size-manager-builder)

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
