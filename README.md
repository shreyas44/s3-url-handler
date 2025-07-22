# S3 URL Handler for macOS

A macOS menu bar application that intercepts `s3://` URLs and opens them in the AWS Console with the appropriate account context.

## Features

- **Menu Bar Only**: Runs in the background with no dock icon, only visible in the menu bar
- **Custom URL Scheme**: Registers and handles `s3://` URLs system-wide
- **Account Management**: Configure multiple AWS accounts with 12-digit account IDs
- **Bucket Mapping**: Map specific S3 buckets to specific AWS accounts
- **Default Account**: Set a default account for unmapped buckets
- **Persistent Configuration**: Settings are saved in `~/Library/Application Support/S3URLHandler/`

## Installation

1. Open the project in Xcode
2. Build and run the application
3. The app will appear in your menu bar with a link icon
4. Grant permission when macOS asks if you want to allow the app to handle `s3://` URLs

## Usage

### Adding AWS Accounts
1. Click the menu bar icon
2. Click the "+" button next to "Accounts"
3. Enter a friendly name and the 12-digit AWS account ID
4. Click "Add"

### Setting a Default Account
1. Click the menu bar icon
2. Use the dropdown under "Default Account" to select an account
3. This account will be used for any buckets not explicitly mapped

### Mapping Buckets to Accounts
1. Click the menu bar icon
2. Click the "+" button next to "Bucket Mappings"
3. Enter the bucket name
4. Select the account from the dropdown
5. Click "Add"

### Opening S3 URLs
Once configured, you can open S3 URLs from anywhere on your system:
- `s3://my-bucket/` - Opens the bucket in AWS Console
- `s3://my-bucket/path/to/file.txt` - Opens the bucket with the path as a prefix filter

The app will automatically:
1. Parse the S3 URL
2. Look up the appropriate account (mapped or default)
3. Construct the AWS Console URL with the account context
4. Open it in your default browser

## URL Format Support

The app supports standard S3 URI format:
```
s3://<bucket-name>/<object-path>
```

These are converted to AWS Console URLs:
```
https://console.aws.amazon.com/s3/buckets/<bucket-name>?prefix=<object-path>&accountId=<account-id>
```

## Building from Source

Requirements:
- macOS 13.0 or later
- Xcode 14.0 or later
- Swift 5.0 or later

Steps:
1. Clone the repository
2. Open `S3URLHandler.xcodeproj` in Xcode
3. Select your development team in project settings
4. Build and run

## Security Note

This app stores AWS account IDs locally but does not store or handle any AWS credentials. It simply constructs URLs that redirect to the AWS Console, where you'll need to authenticate normally.