import SwiftUI
import UserNotifications
import AppKit

// Custom NSTextField that prevents window deactivation
class StableTextField: NSTextField {
    override func becomeFirstResponder() -> Bool {
        if let window = self.window {
            window.makeKey()
        }
        return super.becomeFirstResponder()
    }
}

// SwiftUI wrapper for the stable text field
struct StableTextFieldView: NSViewRepresentable {
    let placeholder: String
    @Binding var text: String
    
    func makeNSView(context: Context) -> NSTextField {
        let textField = StableTextField()
        textField.placeholderString = placeholder
        textField.stringValue = text
        textField.bezelStyle = .roundedBezel
        textField.delegate = context.coordinator
        return textField
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        let parent: StableTextFieldView
        
        init(_ parent: StableTextFieldView) {
            self.parent = parent
        }
        
        func controlTextDidChange(_ obj: Notification) {
            if let textField = obj.object as? NSTextField {
                parent.text = textField.stringValue
            }
        }
    }
}

// Window fix to prevent menu bar popup from disappearing
struct MenuBarWindowFix: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        
        DispatchQueue.main.async {
            if let window = view.window {
                // Configure window to stay visible
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                window.level = .floating
                window.hidesOnDeactivate = false
            }
        }
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

@main
struct S3URLHandlerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var configManager = ConfigurationManager.shared
    
    var body: some Scene {
        MenuBarExtra("S3 URL Handler", systemImage: "link") {
            ContentView()
                .environmentObject(configManager)
                .background(MenuBarWindowFix())
        }
        .menuBarExtraStyle(.window)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
        
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleGetURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }
    
    @objc func handleGetURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent: NSAppleEventDescriptor) {
        print("Received URL event")
        if let urlString = event.forKeyword(AEKeyword(keyDirectObject))?.stringValue {
            print("URL String: \(urlString)")
            if let url = URL(string: urlString) {
                S3URLHandler.shared.handleS3URL(url)
            } else {
                print("Failed to create URL from string: \(urlString)")
            }
        } else {
            print("Failed to extract URL string from event")
        }
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        print("application:open:urls called with \(urls.count) URLs")
        for url in urls {
            print("URL: \(url)")
            if url.scheme == "s3" {
                S3URLHandler.shared.handleS3URL(url)
            } else {
                print("Ignoring non-s3 URL: \(url)")
            }
        }
    }
}