import SwiftUI

struct Theme {
    // Colors
    static let accentColor = Color.blue
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    
    // Platform-agnostic system colors
    static var systemBackground: Color {
        #if os(iOS)
        Color(uiColor: .systemBackground)
        #elseif os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #else
        Color.white
        #endif
    }
    
    static var secondarySystemBackground: Color {
        #if os(iOS)
        Color(uiColor: .secondarySystemBackground)
        #elseif os(macOS)
        Color(nsColor: .controlBackgroundColor)
        #else
        Color.gray.opacity(0.1)
        #endif
    }
    
    // Method colors for HTTP methods
    static func methodColor(for method: String) -> Color {
        switch method.uppercased() {
        case "GET": return .blue
        case "POST": return .green
        case "PUT": return .orange
        case "DELETE": return .red
        case "PATCH": return .purple
        default: return .gray
        }
    }
    
    // Status code colors
    static func statusColor(for code: Int) -> Color {
        switch code {
        case 200..<300: return .green
        case 300..<400: return .yellow
        case 400..<500: return .orange
        case 500..<600: return .red
        default: return .gray
        }
    }
    
    // Console message colors
    static func consoleColor(for type: String) -> Color {
        switch type.lowercased() {
        case "log": return .primary
        case "info": return .blue
        case "warn": return .orange
        case "error": return .red
        default: return .primary
        }
    }
    
    // Spacing
    static let smallSpacing: CGFloat = 4
    static let mediumSpacing: CGFloat = 8
    static let largeSpacing: CGFloat = 16
    
    // Corner radius
    static let smallRadius: CGFloat = 4
    static let mediumRadius: CGFloat = 8
    static let largeRadius: CGFloat = 12
    
    // Icon sizes
    static let smallIconSize: CGFloat = 16
    static let mediumIconSize: CGFloat = 24
    static let largeIconSize: CGFloat = 32
}

// Dark mode support
extension View {
    func themedBackground() -> some View {
        #if os(iOS)
        self.background(Color(uiColor: .systemBackground))
        #elseif os(macOS)
        self.background(Color(nsColor: .windowBackgroundColor))
        #endif
    }
    
    func themedSecondaryBackground() -> some View {
        #if os(iOS)
        self.background(Color(uiColor: .secondarySystemBackground))
        #elseif os(macOS)
        self.background(Color(nsColor: .controlBackgroundColor))
        #endif
    }
}
