import SwiftUI

struct ContentView: View {
    @EnvironmentObject var browserState: BrowserState
    @State private var showDevTools = false
    @State private var selectedDevTool: DevTool?
    @State private var devToolsHeight: CGFloat = 300
    @State private var showTabBar = false
    @State private var showBookmarks = false
    @State private var showSettings = false
    
    enum DevTool: String, CaseIterable, Identifiable {
        case network = "Network"
        case links = "Links"
        case images = "Images"
        case console = "Console"
        case source = "Source"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .network: return "network"
            case .links: return "link"
            case .images: return "photo"
            case .console: return "terminal"
            case .source: return "doc.text"
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Main browser area
                if let tab = browserState.activeTab {
                    BrowserView(tab: tab)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Dev tools panel
                if showDevTools, let tool = selectedDevTool {
                    Divider()
                    
                    devToolsPanel(for: tool)
                        .frame(height: devToolsHeight)
                        .background(Theme.systemBackground)
                }
                
                // Bottom toolbar
                bottomToolbar
            }
            
            // Tab bar overlay
            if showTabBar {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showTabBar = false
                    }
                
                TabBarView(isPresented: $showTabBar)
                    .transition(.move(edge: .top))
            }
            
            // Bookmarks overlay
            if showBookmarks {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showBookmarks = false
                    }
                
                BookmarksView(isPresented: $showBookmarks)
                    .transition(.move(edge: .bottom))
            }
            
            // Settings overlay
            if showSettings {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showSettings = false
                    }
                
                SettingsView(isPresented: $showSettings)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.spring(), value: showTabBar)
        .animation(.spring(), value: showBookmarks)
        .animation(.spring(), value: showSettings)
        .animation(.spring(), value: showDevTools)
    }
    
    @ViewBuilder
    private func devToolsPanel(for tool: DevTool) -> some View {
        VStack(spacing: 0) {
            // Dev tool header
            HStack {
                Text(tool.rawValue)
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showDevTools = false; selectedDevTool = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Theme.secondarySystemBackground)
            
            Divider()
            
            // Dev tool content
            switch tool {
            case .network:
                NetworkMonitorView()
            case .links:
                LinkCaptureView()
            case .images:
                ImageCaptureView()
            case .console:
                JavaScriptConsoleView()
            case .source:
                PageSourceView()
            }
        }
    }
    
    private var bottomToolbar: some View {
        HStack(spacing: 20) {
            Button(action: { showTabBar.toggle() }) {
                Label("Tabs", systemImage: "square.on.square")
                    .labelStyle(.iconOnly)
            }
            
            Button(action: { showBookmarks.toggle() }) {
                Label("Bookmarks", systemImage: "book")
                    .labelStyle(.iconOnly)
            }
            
            Divider()
                .frame(height: 20)
            
            ForEach(DevTool.allCases) { tool in
                Button(action: {
                    if selectedDevTool == tool && showDevTools {
                        showDevTools = false
                        selectedDevTool = nil
                    } else {
                        selectedDevTool = tool
                        showDevTools = true
                    }
                }) {
                    Image(systemName: tool.icon)
                        .foregroundColor(selectedDevTool == tool && showDevTools ? .accentColor : .primary)
                }
            }
            
            Divider()
                .frame(height: 20)
            
            Button(action: { showSettings.toggle() }) {
                Label("Settings", systemImage: "gearshape")
                    .labelStyle(.iconOnly)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}
