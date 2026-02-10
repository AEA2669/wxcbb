import SwiftUI
import WebKit

struct SettingsView: View {
    @EnvironmentObject var browserState: BrowserState
    @Binding var isPresented: Bool
    @State private var customUserAgent = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Search Engine") {
                    Picker("Default Search Engine", selection: $browserState.settings.searchEngine) {
                        ForEach(AppSettings.SearchEngine.allCases, id: \.self) { engine in
                            Text(engine.rawValue).tag(engine)
                        }
                    }
                }
                
                Section("Browser Behavior") {
                    Toggle("Enable JavaScript", isOn: $browserState.settings.javascriptEnabled)
                    Toggle("Block Popups", isOn: $browserState.settings.blockPopups)
                    Toggle("Desktop Mode", isOn: $browserState.settings.desktopMode)
                }
                
                Section("Appearance") {
                    Picker("Theme", selection: $browserState.settings.theme) {
                        ForEach(AppSettings.ThemeMode.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                }
                
                Section("User Agent") {
                    TextField("Custom User Agent", text: $customUserAgent)
                        .font(.caption)
                    
                    Button("Reset to Default") {
                        customUserAgent = ""
                        browserState.settings.userAgent = nil
                    }
                    
                    Button("Apply") {
                        if !customUserAgent.isEmpty {
                            browserState.settings.userAgent = customUserAgent
                        }
                    }
                }
                
                Section("Privacy & Data") {
                    Button("Clear Browsing History") {
                        // Placeholder
                    }
                    
                    Button("Clear Cookies") {
                        clearCookies()
                    }
                    
                    Button("Clear Cache") {
                        clearCache()
                    }
                    
                    Button(role: .destructive) {
                        clearAllData()
                    } label: {
                        Text("Clear All Browsing Data")
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("GitHub Repository", destination: URL(string: "https://github.com/AEA2669/browser-transfer")!)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { isPresented = false }
                }
            }
        }
        .frame(maxWidth: 500)
        .onAppear {
            customUserAgent = browserState.settings.userAgent ?? ""
        }
    }
    
    private func clearCookies() {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            dataStore.removeData(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                for: records.filter { $0.dataTypes.contains(WKWebsiteDataTypeCookies) },
                completionHandler: {}
            )
        }
    }
    
    private func clearCache() {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            dataStore.removeData(
                ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache],
                for: records,
                completionHandler: {}
            )
        }
    }
    
    private func clearAllData() {
        let dataStore = WKWebsiteDataStore.default()
        dataStore.removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: Date(timeIntervalSince1970: 0),
            completionHandler: {}
        )
        
        // Clear app data
        browserState.clearNetworkRequests()
        browserState.clearConsole()
    }
}
