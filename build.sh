#!/usr/bin/env bash

# Exit on error
set -e

# Clone Flutter into a local folder
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Add Flutter to the path
export PATH="$PATH:`pwd`/flutter/bin"

# Run doctor to check (optional)
flutter doctor

# Enable web support
flutter config --enable-web

# Build the project
flutter build web --release