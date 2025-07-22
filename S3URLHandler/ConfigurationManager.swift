import Foundation
import SwiftUI

class ConfigurationManager: ObservableObject {
    static let shared = ConfigurationManager()
    
    @Published var accounts: [String: String] = [:] // name: accountId
    @Published var bucketMappings: [String: String] = [:] // bucket: accountName
    @Published var defaultAccount: String = ""
    
    private let configURL: URL
    
    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = appSupport.appendingPathComponent("S3URLHandler")
        
        try? FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
        
        configURL = appDirectory.appendingPathComponent("config.json")
        
        loadConfiguration()
    }
    
    func loadConfiguration() {
        guard let data = try? Data(contentsOf: configURL),
              let config = try? JSONDecoder().decode(Configuration.self, from: data) else {
            return
        }
        
        accounts = config.accounts
        bucketMappings = config.bucketMappings
        defaultAccount = config.defaultAccount
    }
    
    func saveConfiguration() {
        let config = Configuration(
            accounts: accounts,
            bucketMappings: bucketMappings,
            defaultAccount: defaultAccount
        )
        
        if let data = try? JSONEncoder().encode(config) {
            try? data.write(to: configURL)
        }
    }
    
    func addAccount(name: String, id: String) {
        accounts[name] = id
        saveConfiguration()
    }
    
    func removeAccount(_ name: String) {
        accounts.removeValue(forKey: name)
        
        bucketMappings = bucketMappings.filter { $0.value != name }
        
        if defaultAccount == name {
            defaultAccount = ""
        }
        
        saveConfiguration()
    }
    
    func addBucketMapping(bucket: String, account: String) {
        bucketMappings[bucket] = account
        saveConfiguration()
    }
    
    func removeBucketMapping(_ bucket: String) {
        bucketMappings.removeValue(forKey: bucket)
        saveConfiguration()
    }
}

struct Configuration: Codable {
    let accounts: [String: String]
    let bucketMappings: [String: String]
    let defaultAccount: String
}