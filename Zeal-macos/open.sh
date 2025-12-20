#!/bin/bash
cd "$(dirname "$0")"

APP_PATH="./build/Build/Products/Release/Zeal.app"

if [ -d "$APP_PATH" ]; then
    echo "Opening Zeal..."
    open "$APP_PATH"
else
    echo "Error: App not found at $APP_PATH"
    echo "Please run ./build.sh first."
    exit 1
fi
