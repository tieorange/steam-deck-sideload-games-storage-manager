#!/bin/bash
# Build Linux release using Docker for M-chip Macs
# This script creates a Linux build environment using Docker

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."
IMAGE_NAME="flutter-linux-builder"
CONTAINER_NAME="game-size-manager-build"

echo "🐧 Building Linux release for Game Size Manager"
echo "================================================"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop and try again."
    exit 1
fi

# Create Dockerfile if it doesn't exist
if [ ! -f "$PROJECT_DIR/docker/Dockerfile" ]; then
    echo "📝 Creating Dockerfile..."
    mkdir -p "$PROJECT_DIR/docker"
    cat > "$PROJECT_DIR/docker/Dockerfile" << 'DOCKERFILE'
FROM ubuntu:22.04

# Prevent timezone prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install dependencies
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    file \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    libstdc++-12-dev \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
ENV FLUTTER_VERSION=3.27.2
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"

RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME \
    && flutter precache --linux \
    && flutter doctor -v

WORKDIR /app

DOCKERFILE
fi

# Build Docker image
echo "🔨 Building Docker image (this may take a while the first time)..."
docker build -t "$IMAGE_NAME" -f "$PROJECT_DIR/docker/Dockerfile" "$PROJECT_DIR/docker"

# Run build inside container
echo ""
echo "📦 Building app inside container..."
docker run --rm \
    -v "$PROJECT_DIR:/app" \
    -w /app \
    "$IMAGE_NAME" \
    bash -c "flutter pub get && flutter build linux --release"

# Check if build succeeded
if [ -d "$PROJECT_DIR/build/linux/x64/release/bundle" ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "Output: $PROJECT_DIR/build/linux/x64/release/bundle"
    echo ""
    echo "To deploy to Steam Deck:"
    echo "  1. Copy the bundle folder to your Steam Deck"
    echo "  2. Run ./scripts/install_local.sh on the Steam Deck"
else
    echo ""
    echo "❌ Build failed. Check the output above for errors."
    exit 1
fi
