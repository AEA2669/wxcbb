import Foundation

struct Tab: Identifiable {
    let id: UUID
    var url: URL?
    var title: String
    var favicon: String?
    var isLoading: Bool
    var canGoBack: Bool
    var canGoForward: Bool
    var progress: Double
    var capturedLinks: [CapturedLink]
    var capturedImages: [CapturedImage]
    
    init(url: URL?) {
        self.id = UUID()
        self.url = url
        self.title = url?.host ?? "New Tab"
        self.favicon = nil
        self.isLoading = false
        self.canGoBack = false
        self.canGoForward = false
        self.progress = 0
        self.capturedLinks = []
        self.capturedImages = []
    }
}
