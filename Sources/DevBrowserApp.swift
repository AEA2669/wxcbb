import SwiftUI

@main
struct DevBrowserApp: App {
    @StateObject private var browserState = BrowserState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(browserState)
        }
    }
}

@MainActor
class BrowserState: ObservableObject {
    @Published var tabs: [Tab] = []
    @Published var activeTabIndex: Int = 0
    @Published var bookmarks: [Bookmark] = []
    @Published var networkRequests: [NetworkRequest] = []
    @Published var consoleMessages: [ConsoleMessage] = []
    @Published var settings: AppSettings = AppSettings()
    
    var activeTab: Tab? {
        guard tabs.indices.contains(activeTabIndex) else { return nil }
        return tabs[activeTabIndex]
    }
    
    init() {
        // Create initial tab
        addNewTab()
    }
    
    func addNewTab() {
        let newTab = Tab(url: URL(string: "about:blank"))
        tabs.append(newTab)
        activeTabIndex = tabs.count - 1
    }
    
    func closeTab(at index: Int) {
        guard tabs.count > 1 else { return }
        tabs.remove(at: index)
        if activeTabIndex >= tabs.count {
            activeTabIndex = tabs.count - 1
        }
    }
    
    func addBookmark(_ bookmark: Bookmark) {
        bookmarks.append(bookmark)
    }
    
    func removeBookmark(at index: Int) {
        bookmarks.remove(at: index)
    }
    
    func addNetworkRequest(_ request: NetworkRequest) {
        networkRequests.append(request)
    }
    
    func clearNetworkRequests() {
        networkRequests.removeAll()
    }
    
    func addConsoleMessage(_ message: ConsoleMessage) {
        consoleMessages.append(message)
    }
    
    func clearConsole() {
        consoleMessages.removeAll()
    }
}

struct Bookmark: Identifiable, Codable {
    let id: UUID
    var title: String
    var url: URL
    var createdAt: Date
    
    init(title: String, url: URL) {
        self.id = UUID()
        self.title = title
        self.url = url
        self.createdAt = Date()
    }
}

struct ConsoleMessage: Identifiable {
    let id: UUID
    let type: MessageType
    let message: String
    let timestamp: Date
    
    enum MessageType {
        case log, info, warn, error
        
        var color: Color {
            switch self {
            case .log: return .primary
            case .info: return .blue
            case .warn: return .orange
            case .error: return .red
            }
        }
        
        var icon: String {
            switch self {
            case .log: return "text.bubble"
            case .info: return "info.circle"
            case .warn: return "exclamationmark.triangle"
            case .error: return "xmark.circle"
            }
        }
    }
    
    init(type: MessageType, message: String) {
        self.id = UUID()
        self.type = type
        self.message = message
        self.timestamp = Date()
    }
}

struct AppSettings: Codable {
    var searchEngine: SearchEngine = .google
    var javascriptEnabled: Bool = true
    var userAgent: String?
    var blockPopups: Bool = true
    var theme: ThemeMode = .system
    var desktopMode: Bool = false
    
    enum SearchEngine: String, Codable, CaseIterable {
        case google = "Google"
        case duckduckgo = "DuckDuckGo"
        case bing = "Bing"
        
        var searchURL: String {
            switch self {
            case .google: return "https://www.google.com/search?q="
            case .duckduckgo: return "https://duckduckgo.com/?q="
            case .bing: return "https://www.bing.com/search?q="
            }
        }
    }
    
    enum ThemeMode: String, Codable, CaseIterable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
    }
}
