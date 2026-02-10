import Foundation
import WebKit
import SwiftUI

class WebViewCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    @Binding var tab: Tab
    var browserState: BrowserState
    var webView: WKWebView?
    let userContentController = WKUserContentController()
    
    init(tab: Binding<Tab>, browserState: BrowserState) {
        self._tab = tab
        self.browserState = browserState
        super.init()
        
        // Register message handlers
        userContentController.add(self, name: "linkCapture")
        userContentController.add(self, name: "imageCapture")
        userContentController.add(self, name: "networkCapture")
        userContentController.add(self, name: "consoleCapture")
        
        // Register for navigation notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGoBack),
            name: NSNotification.Name("WebViewGoBack"),
            object: tab.wrappedValue.id
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleGoForward),
            name: NSNotification.Name("WebViewGoForward"),
            object: tab.wrappedValue.id
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleReload),
            name: NSNotification.Name("WebViewReload"),
            object: tab.wrappedValue.id
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStop),
            name: NSNotification.Name("WebViewStop"),
            object: tab.wrappedValue.id
        )
    }
    
    @objc func handleGoBack(_ notification: Notification) {
        webView?.goBack()
    }
    
    @objc func handleGoForward(_ notification: Notification) {
        webView?.goForward()
    }
    
    @objc func handleReload(_ notification: Notification) {
        webView?.reload()
    }
    
    @objc func handleStop(_ notification: Notification) {
        webView?.stopLoading()
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.tab.isLoading = true
            self.tab.progress = 0
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DispatchQueue.main.async {
            self.tab.isLoading = false
            self.tab.progress = 1.0
            self.tab.title = webView.title ?? webView.url?.host ?? "Untitled"
            self.tab.url = webView.url
            self.tab.canGoBack = webView.canGoBack
            self.tab.canGoForward = webView.canGoForward
        }
        
        // Trigger link and image capture
        webView.evaluateJavaScript("captureLinkData()") { _, _ in }
        webView.evaluateJavaScript("captureImageData()") { _, _ in }
        
        #if os(iOS)
        if let refreshControl = webView.scrollView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        #endif
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            self.tab.isLoading = false
            self.tab.progress = 0
        }
        
        #if os(iOS)
        if let refreshControl = webView.scrollView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        #endif
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        DispatchQueue.main.async {
            self.tab.isLoading = false
            self.tab.progress = 0
        }
        
        #if os(iOS)
        if let refreshControl = webView.scrollView.refreshControl, refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
        #endif
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Block popups if setting is enabled
        if browserState.settings.blockPopups && navigationAction.targetFrame == nil {
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    // MARK: - WKUIDelegate
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Handle popup windows by opening in new tab
        if let url = navigationAction.request.url {
            DispatchQueue.main.async {
                let newTab = Tab(url: url)
                self.browserState.tabs.append(newTab)
                self.browserState.activeTabIndex = self.browserState.tabs.count - 1
            }
        }
        return nil
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        DispatchQueue.main.async {
            switch message.name {
            case "linkCapture":
                self.handleLinkCapture(message.body)
            case "imageCapture":
                self.handleImageCapture(message.body)
            case "networkCapture":
                self.handleNetworkCapture(message.body)
            case "consoleCapture":
                self.handleConsoleCapture(message.body)
            default:
                break
            }
        }
    }
    
    private func handleLinkCapture(_ body: Any) {
        guard let data = body as? [[String: Any]] else { return }
        
        var links: [CapturedLink] = []
        for linkData in data {
            guard let urlString = linkData["url"] as? String,
                  let url = URL(string: urlString),
                  let text = linkData["text"] as? String,
                  let isExternal = linkData["external"] as? Bool else {
                continue
            }
            
            links.append(CapturedLink(text: text, url: url, isExternal: isExternal))
        }
        
        tab.capturedLinks = links
    }
    
    private func handleImageCapture(_ body: Any) {
        guard let data = body as? [[String: Any]] else { return }
        
        var images: [CapturedImage] = []
        for imageData in data {
            guard let urlString = imageData["url"] as? String,
                  let url = URL(string: urlString),
                  let sourceString = imageData["source"] as? String else {
                continue
            }
            
            let alt = imageData["alt"] as? String
            let width = imageData["width"] as? Int
            let height = imageData["height"] as? Int
            let source = CapturedImage.ImageSource(rawValue: sourceString) ?? .img
            
            images.append(CapturedImage(url: url, alt: alt, width: width, height: height, source: source))
        }
        
        tab.capturedImages = images
    }
    
    private func handleNetworkCapture(_ body: Any) {
        guard let data = body as? [String: Any],
              let methodString = data["method"] as? String,
              let urlString = data["url"] as? String,
              let url = URL(string: urlString) else {
            return
        }
        
        let method = NetworkRequest.HTTPMethod(rawValue: methodString.uppercased()) ?? .GET
        let typeString = data["type"] as? String ?? "xhr"
        let type: NetworkRequest.RequestType = typeString == "fetch" ? .fetch : .xhr
        
        var request = NetworkRequest(method: method, url: url, type: type)
        request.statusCode = data["status"] as? Int
        request.duration = data["duration"] as? TimeInterval
        request.requestBody = data["requestBody"] as? String
        request.responseBody = data["responseBody"] as? String
        request.contentType = data["contentType"] as? String
        
        browserState.addNetworkRequest(request)
    }
    
    private func handleConsoleCapture(_ body: Any) {
        guard let data = body as? [String: Any],
              let typeString = data["type"] as? String,
              let message = data["message"] as? String else {
            return
        }
        
        let messageType: ConsoleMessage.MessageType = {
            switch typeString {
            case "log": return .log
            case "info": return .info
            case "warn": return .warn
            case "error": return .error
            default: return .log
            }
        }()
        
        let consoleMessage = ConsoleMessage(type: messageType, message: message)
        browserState.addConsoleMessage(consoleMessage)
    }
    
    // MARK: - Actions
    
    @objc func refresh() {
        webView?.reload()
    }
    
    deinit {
        userContentController.removeScriptMessageHandler(forName: "linkCapture")
        userContentController.removeScriptMessageHandler(forName: "imageCapture")
        userContentController.removeScriptMessageHandler(forName: "networkCapture")
        userContentController.removeScriptMessageHandler(forName: "consoleCapture")
        
        NotificationCenter.default.removeObserver(self)
    }
}
