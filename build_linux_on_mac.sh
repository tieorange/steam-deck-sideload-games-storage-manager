#!/bin/bash
# Build Linux release on macOS using Docker
echo "🐳 Starting Linux build in Docker..."

# Use a Flutter image that includes Linux toolchain
# ghcr.io/cirruslabs/flutter gets updated regularly
IMAGE="ghcr.io/cirruslabs/flutter:stable"

# Ensure output directory exists and is clean
rm -f game_size_manager_linux.zip

# Add Docker binaries to PATH (fixes credential helper issue)
export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin"

# Docker executable path
DOCKER_CMD="docker"

# Run build
$DOCKER_CMD run --rm \
  --platform linux/amd64 \
  -v "$(pwd):/app" \
  -w /app \
  $IMAGE \
  /bin/bash -c "
    echo '📥 Installing build dependencies...' && \
    sudo apt-get update && \
    sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libsqlite3-dev libcurl4-openssl-dev zip && \
    echo '📥 Getting dependencies...' && \
    flutter config --no-analytics && \
    flutter pub get && \
    echo '🔨 Building Release...' && \
    flutter build linux --release && \
    echo '📦 Zipping artifact...' && \
    cd build/linux/x64/release/bundle && \
    zip -r /app/game_size_manager_linux.zip .
  "

if [ -f "game_size_manager_linux.zip" ]; then
    echo "✅ Build success! Artifact: game_size_manager_linux.zip"
else
    echo "❌ Build failed or artifact not found."
    exit 1
fi
