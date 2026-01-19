#!/bin/bash
# Build Linux release on macOS using Docker
echo "🐳 Starting Linux build in Docker..."

# Use a Flutter image that includes Linux toolchain
# ghcr.io/cirruslabs/flutter gets updated regularly
IMAGE="ghcr.io/cirruslabs/flutter:3.27.1"

# Ensure output directory exists and is clean
rm -f game_size_manager_linux.zip

# Run build
docker run --rm \
  --platform linux/amd64 \
  -v "$(pwd):/app" \
  -w /app \
  $IMAGE \
  /bin/bash -c "
    echo '📥 Getting dependencies...' && \
    flutter config --no-analytics && \
    flutter pub get && \
    echo '🔨 Building Release...' && \
    flutter build linux --release && \
    echo '📦 Zipping artifact...' && \
    cd build/linux/x64/release/bundle && \
    apt-get update && apt-get install -y zip && \
    zip -r /app/game_size_manager_linux.zip .
  "

if [ -f "game_size_manager_linux.zip" ]; then
    echo "✅ Build success! Artifact: game_size_manager_linux.zip"
else
    echo "❌ Build failed or artifact not found."
    exit 1
fi
