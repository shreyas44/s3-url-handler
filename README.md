# S3URLHandler

A macOS menu bar application that handles `s3://` URLs and opens them in the AWS Console with the appropriate account context.

## Features

- 🔗 Handles `s3://` URL scheme system-wide
- 🗂️ Maps S3 buckets to specific AWS accounts
- 🎯 Opens S3 URLs directly in AWS Console with the correct account
- 🖱️ Lives in your menu bar for easy access
- ⚡ Quick account switching support

## Installation

### Quick Install (Recommended)

Download and install the pre-built application with a single command:

```bash
curl -fsSL https://raw.githubusercontent.com/shreyas44/s3-url-handler/main/quick-install.sh | bash
```

This will automatically download, extract, and install S3URLHandler to your Applications folder.

### Install from Source

Build and install from source code:

```bash
git clone https://github.com/shreyas44/s3-url-handler.git
cd s3-url-handler
./install-from-source.sh
```

### Manual Build

For more control over the build process:

```bash
git clone https://github.com/shreyas44/s3-url-handler.git
cd s3-url-handler
./build.sh
```

The `build.sh` script provides interactive options for:
- Building the app
- Installing to `/Applications`
- Launching the app
- Cleaning up build artifacts

### Build from Xcode

1. Open `S3URLHandler.xcodeproj` in Xcode
2. Select Product > Archive
3. Export the archive as a macOS App
4. Copy to `/Applications`

## Usage

1. **Launch the app** - It will appear in your menu bar
2. **Add AWS accounts** - Click the menu bar icon and add your AWS accounts with their 12-digit IDs
3. **Map S3 buckets** - Associate specific buckets with accounts
4. **Click S3 URLs** - Any `s3://bucket/path` URL will open in AWS Console

### Adding Accounts

1. Click the S3URLHandler icon in the menu bar
2. Click "Add Account"
3. Enter a friendly name and the 12-digit AWS account ID
4. Click "Add"

### Mapping Buckets

1. Click the S3URLHandler icon in the menu bar
2. Click the "+" next to "Bucket Mappings"
3. Enter the bucket name
4. Select the associated account
5. Click "Add"

### URL Format

S3URLHandler recognizes URLs in the format:
```
s3://bucket-name/path/to/object
```

When clicked, these will open in AWS Console with the appropriate account context.

## Launch at Login

To have S3URLHandler start automatically:

1. Open System Preferences
2. Go to Users & Groups
3. Select your user and click "Login Items"
4. Click "+" and add S3URLHandler from `/Applications`

## Troubleshooting

### App doesn't appear in menu bar
- Make sure the app is running (check Activity Monitor)
- Try launching from `/Applications/S3URLHandler.app`

### S3 URLs don't open
- Ensure S3URLHandler is set as the default handler for `s3://` URLs
- Check that the bucket is mapped to an account
- Verify the account ID is correct

### Build fails
- Ensure Xcode or Xcode Command Line Tools are installed
- Run `xcode-select --install` if needed
- Check that you have the latest version of Xcode

## Requirements

- macOS 11.0 or later
- Xcode 13.0 or later (for building)

## License

[Your License Here]