import Foundation

struct NetworkRequest: Identifiable {
    let id: UUID
    let method: HTTPMethod
    let url: URL
    let timestamp: Date
    var statusCode: Int?
    var duration: TimeInterval?
    var requestHeaders: [String: String]?
    var responseHeaders: [String: String]?
    var requestBody: String?
    var responseBody: String?
    var contentType: String?
    var type: RequestType
    
    enum HTTPMethod: String {
        case GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS, CONNECT, TRACE
        
        var color: String {
            switch self {
            case .GET: return "blue"
            case .POST: return "green"
            case .PUT: return "orange"
            case .DELETE: return "red"
            case .PATCH: return "purple"
            default: return "gray"
            }
        }
    }
    
    enum RequestType: String {
        case xhr = "XHR"
        case fetch = "Fetch"
        case websocket = "WebSocket"
        case document = "Doc"
        case stylesheet = "CSS"
        case script = "JS"
        case image = "Image"
        case font = "Font"
        case media = "Media"
        case other = "Other"
        
        static func from(contentType: String?) -> RequestType {
            guard let type = contentType else { return .other }
            
            if type.contains("javascript") || type.contains("ecmascript") {
                return .script
            } else if type.contains("css") {
                return .stylesheet
            } else if type.contains("image") {
                return .image
            } else if type.contains("font") {
                return .font
            } else if type.contains("video") || type.contains("audio") {
                return .media
            } else if type.contains("html") {
                return .document
            }
            
            return .other
        }
    }
    
    var statusColor: String {
        guard let code = statusCode else { return "gray" }
        
        switch code {
        case 200..<300: return "green"
        case 300..<400: return "yellow"
        case 400..<500: return "orange"
        case 500..<600: return "red"
        default: return "gray"
        }
    }
    
    init(method: HTTPMethod, url: URL, type: RequestType) {
        self.id = UUID()
        self.method = method
        self.url = url
        self.timestamp = Date()
        self.type = type
    }
}
