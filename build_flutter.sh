#!/bin/bash

# Install Flutter for Netlify build
set -e

# Cache directory for Flutter
CACHE_DIR="$HOME/.cache/flutter"
FLUTTER_DIR="/tmp/flutter"
FLUTTER_SDK="$FLUTTER_DIR/flutter"

echo "Installing Flutter..."

# Use cached Flutter if available
if [ -d "$CACHE_DIR/flutter" ]; then
    echo "Using cached Flutter..."
    cp -r "$CACHE_DIR/flutter" "$FLUTTER_SDK"
else
    # Remove old Flutter installation if exists
    rm -rf "$FLUTTER_DIR"
    mkdir -p "$FLUTTER_DIR"

    # Clone Flutter SDK (using stable channel)
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_SDK"
fi

# Add Flutter to PATH
export PATH="$FLUTTER_SDK/bin:$PATH"

# Verify Flutter installation
flutter --version

# Cache Flutter for future builds
mkdir -p "$CACHE_DIR"
cp -r "$FLUTTER_SDK" "$CACHE_DIR/"

# Enable web support
flutter config --enable-web

# Get dependencies
flutter pub get

# Build the web app
flutter build web --base-href /

echo "Flutter build completed successfully!"
