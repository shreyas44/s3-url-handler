#!/bin/bash

# S3URLHandler Build and Install Script
# This script builds the S3URLHandler app and installs it to /Applications

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    print_error "Xcode or Xcode Command Line Tools not found!"
    print_info "Please install Xcode from the App Store or run: xcode-select --install"
    exit 1
fi

print_info "Starting S3URLHandler build process..."

# Clean previous builds
print_status "Cleaning previous builds..."
rm -rf build/
xcodebuild clean -quiet

# Build the app
print_status "Building S3URLHandler..."
xcodebuild -project S3URLHandler.xcodeproj \
           -scheme S3URLHandler \
           -configuration Release \
           -derivedDataPath build \
           -quiet \
           PRODUCT_BUNDLE_IDENTIFIER=com.yourcompany.S3URLHandler \
           CODE_SIGN_IDENTITY="-" \
           CODE_SIGNING_REQUIRED=NO

# Check if build was successful
if [ $? -eq 0 ]; then
    print_status "Build completed successfully!"
else
    print_error "Build failed!"
    exit 1
fi

# Find the built app
APP_PATH=$(find build -name "S3URLHandler.app" -type d | head -n 1)

if [ -z "$APP_PATH" ]; then
    print_error "Could not find built app!"
    exit 1
fi

print_status "Found app at: $APP_PATH"

# Ask user if they want to install
read -p "Do you want to install S3URLHandler to /Applications? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Check if app already exists
    if [ -d "/Applications/S3URLHandler.app" ]; then
        print_info "S3URLHandler.app already exists in /Applications"
        read -p "Do you want to replace it? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Kill the app if it's running
            if pgrep -x "S3URLHandler" > /dev/null; then
                print_info "S3URLHandler is running. Stopping it..."
                killall S3URLHandler
                sleep 1
            fi
            
            print_status "Removing old installation..."
            rm -rf /Applications/S3URLHandler.app
        else
            print_info "Installation cancelled."
            exit 0
        fi
    fi
    
    # Copy to Applications
    print_status "Installing to /Applications..."
    cp -R "$APP_PATH" /Applications/
    
    # Set proper permissions
    chmod -R 755 /Applications/S3URLHandler.app
    
    print_status "Installation complete!"
    
    # Ask if user wants to launch the app
    read -p "Do you want to launch S3URLHandler now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Launching S3URLHandler..."
        open /Applications/S3URLHandler.app
    fi
    
    print_info "S3URLHandler is installed and ready to use!"
    print_info "The app will appear in your menu bar when running."
    print_info "You can configure it to launch at login in System Preferences > Users & Groups > Login Items"
else
    print_info "Installation skipped. The built app is available at:"
    print_info "$APP_PATH"
fi

# Cleanup build artifacts (optional)
read -p "Do you want to clean up build artifacts? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Cleaning up..."
    rm -rf build/
    xcodebuild clean -quiet
    print_status "Cleanup complete!"
fi

print_status "All done!"