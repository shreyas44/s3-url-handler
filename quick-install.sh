#!/bin/bash

# S3URLHandler Quick Install Script
# Builds and installs S3URLHandler with minimal prompts

set -e

echo "🚀 S3URLHandler Quick Install"
echo "============================"
echo ""

# Check for Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ xcodebuild not found!"
    echo "   Please install Xcode from the App Store"
    exit 1
fi

# Check if full Xcode is installed (not just Command Line Tools)
if xcodebuild -version &>/dev/null; then
    echo "📋 Xcode version:"
    xcodebuild -version
    echo ""
else
    echo "❌ Error: Full Xcode installation required"
    echo ""
    echo "You have Command Line Tools installed, but building iOS/macOS apps requires the full Xcode."
    echo ""
    echo "To fix this:"
    echo "1. Install Xcode from the Mac App Store"
    echo "2. Once installed, run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
    echo "3. Then run this script again"
    echo ""
    echo "Alternative: If you have Xcode installed in a different location:"
    echo "   sudo xcode-select -s /path/to/Xcode.app/Contents/Developer"
    exit 1
fi

# Stop app if running
if pgrep -x "S3URLHandler" > /dev/null; then
    echo "⏹  Stopping S3URLHandler..."
    killall S3URLHandler
    sleep 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf build/
xcodebuild clean -quiet 2>/dev/null || true

# Build
echo "🔨 Building S3URLHandler..."
echo "   This may take a minute..."
echo ""

if xcodebuild -project S3URLHandler.xcodeproj \
           -scheme S3URLHandler \
           -configuration Release \
           -derivedDataPath build \
           CODE_SIGN_IDENTITY="-" \
           CODE_SIGNING_REQUIRED=NO; then
    echo ""
    echo "✅ Build completed successfully!"
else
    echo ""
    echo "❌ Build failed!"
    echo ""
    echo "Common issues:"
    echo "- Missing scheme: Open the project in Xcode once to generate schemes"
    echo "- Code signing: The script attempts to skip code signing, but Xcode settings may override this"
    echo "- Missing dependencies: Ensure all Swift packages are resolved"
    exit 1
fi

# Find and install
echo ""
echo "🔍 Looking for built app..."
APP_PATH=$(find build -name "S3URLHandler.app" -type d | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo "❌ Could not find built app!"
    echo "Contents of build directory:"
    find build -type d -name "*.app" 2>&1 || echo "No .app bundles found"
    exit 1
fi

echo "✅ Found app at: $APP_PATH"
echo ""

# Remove old installation if exists
if [ -d "/Applications/S3URLHandler.app" ]; then
    echo "📦 Removing old installation..."
    rm -rf /Applications/S3URLHandler.app 2>/dev/null || {
        echo "❌ Failed to remove old app. You may need sudo permissions."
        echo "   Try: sudo rm -rf /Applications/S3URLHandler.app"
        exit 1
    }
fi

# Copy new app
echo "📦 Installing to /Applications..."
if cp -R "$APP_PATH" /Applications/ 2>&1; then
    echo "✅ App copied successfully!"
    chmod -R 755 /Applications/S3URLHandler.app
else
    echo "❌ Failed to copy app to /Applications!"
    echo "   You may need to run with sudo: sudo $0"
    exit 1
fi

# Cleanup
echo "🧹 Cleaning up build artifacts..."
rm -rf build/

# Launch
echo "🚀 Launching S3URLHandler..."
if open /Applications/S3URLHandler.app 2>&1; then
    echo ""
    echo "✅ S3URLHandler installed successfully!"
    echo "   The app is now running in your menu bar."
    echo ""
    echo "💡 To have it launch at login:"
    echo "   System Preferences > Users & Groups > Login Items > Add S3URLHandler"
else
    echo "❌ Failed to launch the app!"
    echo "   Try launching manually from /Applications"
    exit 1
fi