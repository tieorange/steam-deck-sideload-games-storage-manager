# Dockerfile for building Flutter Linux app
FROM ubuntu:22.04

# Prerequisites
RUN apt-get update && apt-get install -y \
    curl \
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
    libsqlite3-dev

# Install Flutter
ENV FLUTTER_HOME=/usr/local/flutter
ENV PATH=$FLUTTER_HOME/bin:$PATH

ARG FLUTTER_VERSION=3.16.0
RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME && \
    cd $FLUTTER_HOME && \
    git checkout stable

RUN flutter config --no-analytics
RUN flutter precache --linux

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Get dependencies
RUN flutter pub get

# Build
RUN flutter build linux --release

# Output binary is in /app/build/linux/x64/release/bundle/
