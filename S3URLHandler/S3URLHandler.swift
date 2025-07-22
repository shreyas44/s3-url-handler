import Foundation
import AppKit
import UserNotifications

class S3URLHandler {
    static let shared = S3URLHandler()
    
    private init() {}
    
    func handleS3URL(_ url: URL) {
        guard url.scheme == "s3" else { 
            print("URL scheme is not s3: \(url.scheme ?? "nil")")
            return 
        }
        
        let bucket = url.host ?? ""
        let path = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        
        print("Handling S3 URL: \(url)")
        print("Bucket: \(bucket)")
        print("Path: \(path)")
        
        let consoleURL = buildConsoleURL(bucket: bucket, path: path)
        
        if let consoleURL = consoleURL {
            print("Opening AWS Console URL: \(consoleURL)")
            
            // Show notification for debugging
            let content = UNMutableNotificationContent()
            content.title = "S3 URL Handler"
            content.body = "Opening bucket: \(bucket)"
            content.sound = .default
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Notification error: \(error)")
                }
            }
            
            NSWorkspace.shared.open(consoleURL)
        } else {
            print("Failed to build console URL")
            
            // Show error notification
            let content = UNMutableNotificationContent()
            content.title = "S3 URL Handler Error"
            content.body = "Failed to build AWS Console URL"
            content.sound = .default
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Notification error: \(error)")
                }
            }
        }
    }
    
    private func buildConsoleURL(bucket: String, path: String) -> URL? {
        let config = ConfigurationManager.shared
        
        var accountID: String?
        
        if let mappedAccount = config.bucketMappings[bucket],
           let id = config.accounts[mappedAccount] {
            accountID = id
        } else if !config.defaultAccount.isEmpty,
                  let id = config.accounts[config.defaultAccount] {
            accountID = id
        }
        
        var urlString = "https://console.aws.amazon.com/s3/buckets/\(bucket)"
        
        if !path.isEmpty {
            // Ensure path ends with a trailing slash
            var normalizedPath = path
            if !normalizedPath.hasSuffix("/") {
                normalizedPath += "/"
            }
            urlString += "?prefix=\(normalizedPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? normalizedPath)"
        }
        
        if let accountID = accountID {
            urlString += "&accountId=\(accountID)"
        }
        
        return URL(string: urlString)
    }
}