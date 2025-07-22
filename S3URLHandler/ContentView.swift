import SwiftUI

struct ContentView: View {
    @EnvironmentObject var configManager: ConfigurationManager
    @State private var showingAddAccount = false
    @State private var newAccountName = ""
    @State private var newAccountID = ""
    @State private var selectedBucket = ""
    @State private var selectedAccount = ""
    @State private var showingAddBucketMapping = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text("S3 URL Handler")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Default Account")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Default Account", selection: $configManager.defaultAccount) {
                        Text("None").tag("")
                        ForEach(configManager.accounts.keys.sorted(), id: \.self) { accountName in
                            Text(accountName).tag(accountName)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: configManager.defaultAccount) { _ in
                        configManager.saveConfiguration()
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Accounts")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: {
                            showingAddAccount = true
                        }) {
                            Image(systemName: "plus.circle")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    ForEach(configManager.accounts.keys.sorted(), id: \.self) { accountName in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(accountName)
                                    .font(.caption)
                                Text(configManager.accounts[accountName] ?? "")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                configManager.removeAccount(accountName)
                            }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Bucket Mappings")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: {
                            showingAddBucketMapping.toggle()
                            selectedBucket = ""
                            selectedAccount = ""
                        }) {
                            Image(systemName: showingAddBucketMapping ? "minus.circle" : "plus.circle")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    if showingAddBucketMapping {
                        HStack {
                            StableTextFieldView(placeholder: "Bucket name", text: $selectedBucket)
                            
                            Picker("Account", selection: $selectedAccount) {
                                Text("Select").tag("")
                                ForEach(configManager.accounts.keys.sorted(), id: \.self) { accountName in
                                    Text(accountName).tag(accountName)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 100)
                            
                            Button("Add") {
                                if !selectedBucket.isEmpty && !selectedAccount.isEmpty {
                                    configManager.addBucketMapping(bucket: selectedBucket, account: selectedAccount)
                                    selectedBucket = ""
                                    selectedAccount = ""
                                    showingAddBucketMapping = false
                                }
                            }
                            .disabled(selectedBucket.isEmpty || selectedAccount.isEmpty)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    ForEach(configManager.bucketMappings.keys.sorted(), id: \.self) { bucket in
                        HStack {
                            Text(bucket)
                                .font(.caption)
                            
                            Spacer()
                            
                            Text(configManager.bucketMappings[bucket] ?? "")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Button(action: {
                                configManager.removeBucketMapping(bucket)
                            }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            
            Divider()
            
            HStack {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .padding()
            }
        }
        .frame(width: 350)
        .overlay(
            Group {
                if showingAddAccount {
                    ZStack {
                        // Background that blocks clicks
                        Color.black.opacity(0.3)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                // Close when clicking background
                                newAccountName = ""
                                newAccountID = ""
                                showingAddAccount = false
                            }
                        
                        // The actual popup content
                        VStack(spacing: 16) {
                            Text("Add AWS Account")
                                .font(.headline)
                            
                            StableTextFieldView(placeholder: "Account Name", text: $newAccountName)
                            
                            StableTextFieldView(placeholder: "Account ID (12 digits)", text: $newAccountID)
                            
                            HStack {
                                Button("Cancel") {
                                    newAccountName = ""
                                    newAccountID = ""
                                    showingAddAccount = false
                                }
                                .buttonStyle(.bordered)
                                
                                Spacer()
                                
                                Button("Add") {
                                    if !newAccountName.isEmpty && newAccountID.count == 12 {
                                        configManager.addAccount(name: newAccountName, id: newAccountID)
                                        newAccountName = ""
                                        newAccountID = ""
                                        showingAddAccount = false
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                                .foregroundColor(.white)
                                .disabled(newAccountName.isEmpty || newAccountID.count != 12)
                            }
                        }
                        .padding()
                        .frame(width: 300)
                        .background(Color(NSColor.windowBackgroundColor))
                        .cornerRadius(10)
                        .shadow(radius: 10)
                        .onTapGesture {
                            // Prevent clicks on the popup from closing it
                        }
                        .onAppear {
                            // Force the window to take focus
                            NSApp.activate(ignoringOtherApps: true)
                        }
                    }
                }
            }
        )
    }
}