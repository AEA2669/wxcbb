import SwiftUI
import WebKit

struct BrowserView: View {
    @EnvironmentObject var browserState: BrowserState
    @State var tab: Tab
    @State private var urlText: String = ""
    @State private var showURLBar = true
    @FocusState private var isURLFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Top toolbar with URL bar
            if showURLBar {
                urlBar
            }
            
            // Progress bar
            if tab.isLoading {
                ProgressView(value: tab.progress)
                    .progressViewStyle(.linear)
            }
            
            // WebView
            WebViewRepresentable(tab: $tab)
                .environmentObject(browserState)
        }
        .onAppear {
            urlText = tab.url?.absoluteString ?? ""
        }
        .onChange(of: tab.url) { oldValue, newValue in
            urlText = newValue?.absoluteString ?? ""
        }
    }
    
    private var urlBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // Back button
                Button(action: goBack) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(tab.canGoBack ? .primary : .gray)
                }
                .disabled(!tab.canGoBack)
                
                // Forward button
                Button(action: goForward) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(tab.canGoForward ? .primary : .gray)
                }
                .disabled(!tab.canGoForward)
                
                // URL TextField
                HStack {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                        .opacity(tab.url?.scheme == "https" ? 1 : 0)
                    
                    TextField("Search or enter URL", text: $urlText)
                        .textFieldStyle(.plain)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                        .focused($isURLFieldFocused)
                        .onSubmit {
                            loadURL()
                        }
                    
                    if !urlText.isEmpty {
                        Button(action: { urlText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(8)
                .background(Color(uiColor: .secondarySystemBackground))
                .cornerRadius(10)
                
                // Reload/Stop button
                Button(action: reloadOrStop) {
                    Image(systemName: tab.isLoading ? "xmark" : "arrow.clockwise")
                }
                
                // Home button
                Button(action: goHome) {
                    Image(systemName: "house")
                }
                
                // Bookmark button
                Button(action: addBookmark) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            
            Divider()
        }
    }
    
    private var isBookmarked: Bool {
        guard let url = tab.url else { return false }
        return browserState.bookmarks.contains { $0.url == url }
    }
    
    private func loadURL() {
        isURLFieldFocused = false
        
        var urlString = urlText.trimmingCharacters(in: .whitespaces)
        
        // Check if it's a URL or search query
        if urlString.contains(".") && !urlString.contains(" ") {
            // Likely a URL
            if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
                urlString = "https://" + urlString
            }
        } else {
            // Search query
            let encoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            urlString = browserState.settings.searchEngine.searchURL + encoded
        }
        
        if let url = URL(string: urlString) {
            tab.url = url
            // The WebView will reload via the coordinator
        }
    }
    
    private func goBack() {
        // Send message to WebView to go back
        NotificationCenter.default.post(name: NSNotification.Name("WebViewGoBack"), object: tab.id)
    }
    
    private func goForward() {
        // Send message to WebView to go forward
        NotificationCenter.default.post(name: NSNotification.Name("WebViewGoForward"), object: tab.id)
    }
    
    private func reloadOrStop() {
        if tab.isLoading {
            NotificationCenter.default.post(name: NSNotification.Name("WebViewStop"), object: tab.id)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("WebViewReload"), object: tab.id)
        }
    }
    
    private func goHome() {
        tab.url = URL(string: "about:blank")
    }
    
    private func addBookmark() {
        guard let url = tab.url, url.absoluteString != "about:blank" else { return }
        
        if isBookmarked {
            // Remove bookmark
            if let index = browserState.bookmarks.firstIndex(where: { $0.url == url }) {
                browserState.removeBookmark(at: index)
            }
        } else {
            // Add bookmark
            let bookmark = Bookmark(title: tab.title, url: url)
            browserState.addBookmark(bookmark)
        }
    }
}
