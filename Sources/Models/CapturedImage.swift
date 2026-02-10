import Foundation

struct CapturedImage: Identifiable, Hashable {
    let id: UUID
    let url: URL
    let alt: String?
    let width: Int?
    let height: Int?
    let source: ImageSource
    let timestamp: Date
    
    enum ImageSource: String {
        case img = "IMG Tag"
        case background = "CSS Background"
        case picture = "Picture Element"
        case srcset = "Srcset"
    }
    
    init(url: URL, alt: String?, width: Int?, height: Int?, source: ImageSource) {
        self.id = UUID()
        self.url = url
        self.alt = alt
        self.width = width
        self.height = height
        self.source = source
        self.timestamp = Date()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CapturedImage, rhs: CapturedImage) -> Bool {
        lhs.id == rhs.id
    }
}
