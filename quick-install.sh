#!/bin/bash

set -e

DOWNLOAD_URL="https://github.com/user-attachments/files/21376745/S3URLHandler.app.zip"
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

# Verify the app bundle exists
if [ ! -d "$APP_NAME.app" ]; then
    echo "❌ Error: $APP_NAME.app not found after extraction"
    ls -la
    exit 1
fi

# Check if the executable exists
if [ ! -f "$APP_NAME.app/Contents/MacOS/$APP_NAME" ]; then
    echo "❌ Error: Executable not found at $APP_NAME.app/Contents/MacOS/$APP_NAME"
    echo "Contents of MacOS folder:"
    ls -la "$APP_NAME.app/Contents/MacOS/" 2>/dev/null || echo "MacOS folder not found"
    exit 1
fi

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

echo "🔧 Fixing permissions..."
# Make the app bundle executable
chmod -R 755 "/Applications/$APP_NAME.app"
# Ensure the main executable has proper permissions
find "/Applications/$APP_NAME.app/Contents/MacOS" -type f -exec chmod +x {} \;

echo "🔓 Removing all extended attributes..."
# Remove ALL extended attributes recursively
find "/Applications/$APP_NAME.app" -type f -exec xattr -c {} \; 2>/dev/null || true
find "/Applications/$APP_NAME.app" -type d -exec xattr -c {} \; 2>/dev/null || true

echo "✍️  Applying ad-hoc signature..."
# Force re-sign with ad-hoc signature
codesign --force --deep --sign - "/Applications/$APP_NAME.app"

# Verify the signature
echo "🔍 Verifying signature..."
if codesign --verify --verbose "/Applications/$APP_NAME.app" 2>&1; then
    echo "✅ Signature verified successfully"
else
    echo "⚠️  Warning: Signature verification failed, but the app may still work"
fi

echo "🧹 Cleaning up..."
rm -rf "$TEMP_DIR"

echo "✅ Installation complete!"
echo
echo "ℹ️  Note: If macOS blocks the app:"
echo "   1. Right-click on $APP_NAME in /Applications"
echo "   2. Select 'Open' from the context menu"
echo "   3. Click 'Open' in the security dialog"
echo "   (You only need to do this once)"
echo

read -p "Would you like to launch $APP_NAME now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Launching $APP_NAME..."
    open "/Applications/$APP_NAME.app"
fi

echo "✨ Done! $APP_NAME is ready to use."
