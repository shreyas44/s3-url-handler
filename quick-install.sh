#!/bin/bash

set -e

DOWNLOAD_URL="https://github.com/user-attachments/files/21376603/S3URLHandler.app.zip"
APP_NAME="S3URLHandler"
TEMP_DIR=$(mktemp -d)
ZIP_FILE="$TEMP_DIR/$APP_NAME.app.zip"

echo "🚀 S3URLHandler Quick Install"
echo "============================"
echo

echo "📥 Downloading $APP_NAME..."
curl -L "$DOWNLOAD_URL" -o "$ZIP_FILE"

echo "📦 Extracting application..."
cd "$TEMP_DIR"
unzip -q "$ZIP_FILE"

if [ -d "/Applications/$APP_NAME.app" ]; then
    echo "⚠️  $APP_NAME already exists in /Applications"
    read -p "Do you want to replace it? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Removing existing application..."
        rm -rf "/Applications/$APP_NAME.app"
    else
        echo "❌ Installation cancelled"
        rm -rf "$TEMP_DIR"
        exit 1
    fi
fi

echo "📱 Installing $APP_NAME to /Applications..."
mv "$APP_NAME.app" /Applications/

echo "🧹 Cleaning up..."
rm -rf "$TEMP_DIR"

echo "✅ Installation complete!"
echo

read -p "Would you like to launch $APP_NAME now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Launching $APP_NAME..."
    open "/Applications/$APP_NAME.app"
fi

echo "✨ Done! $APP_NAME is ready to use."