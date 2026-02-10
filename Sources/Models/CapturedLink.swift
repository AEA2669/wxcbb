import Foundation

struct CapturedLink: Identifiable, Hashable {
    let id: UUID
    let text: String
    let url: URL
    let isExternal: Bool
    let timestamp: Date
    
    init(text: String, url: URL, isExternal: Bool) {
        self.id = UUID()
        self.text = text
        self.url = url
        self.isExternal = isExternal
        self.timestamp = Date()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CapturedLink, rhs: CapturedLink) -> Bool {
        lhs.id == rhs.id
    }
}
