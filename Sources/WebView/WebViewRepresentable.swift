import SwiftUI
import WebKit

#if os(iOS)
typealias ViewRepresentable = UIViewRepresentable
#elseif os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#endif

struct WebViewRepresentable: ViewRepresentable {
    @Binding var tab: Tab
    @EnvironmentObject var browserState: BrowserState
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(tab: $tab, browserState: browserState)
    }
    
    #if os(iOS)
    func makeUIView(context: Context) -> WKWebView {
        let webView = createWebView(coordinator: context.coordinator)
        loadInitialURL(webView)
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Update if needed
    }
    #elseif os(macOS)
    func makeNSView(context: Context) -> WKWebView {
        let webView = createWebView(coordinator: context.coordinator)
        loadInitialURL(webView)
        return webView
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) {
        // Update if needed
    }
    #endif
    
    private func createWebView(coordinator: WebViewCoordinator) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = coordinator.userContentController
        
        // Add user scripts for link/image/network capture
        let linkCaptureScript = WKUserScript(
            source: UserScripts.linkCaptureScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(linkCaptureScript)
        
        let imageCaptureScript = WKUserScript(
            source: UserScripts.imageCaptureScript,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(imageCaptureScript)
        
        let networkCaptureScript = WKUserScript(
            source: UserScripts.networkCaptureScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(networkCaptureScript)
        
        let consoleCaptureScript = WKUserScript(
            source: UserScripts.consoleCaptureScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(consoleCaptureScript)
        
        // Configure preferences
        configuration.preferences.javaScriptEnabled = browserState.settings.javascriptEnabled
        configuration.defaultWebpagePreferences.allowsContentJavaScript = browserState.settings.javascriptEnabled
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = coordinator
        webView.uiDelegate = coordinator
        
        // Set custom user agent if provided
        if let userAgent = browserState.settings.userAgent {
            webView.customUserAgent = userAgent
        } else if browserState.settings.desktopMode {
            webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        }
        
        #if os(iOS)
        webView.scrollView.refreshControl = UIRefreshControl()
        webView.scrollView.refreshControl?.addTarget(coordinator, action: #selector(coordinator.refresh), for: .valueChanged)
        webView.allowsBackForwardNavigationGestures = true
        #endif
        
        coordinator.webView = webView
        
        return webView
    }
    
    private func loadInitialURL(_ webView: WKWebView) {
        if let url = tab.url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
