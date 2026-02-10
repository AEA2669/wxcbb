import SwiftUI

struct PageSourceView: View {
    @EnvironmentObject var browserState: BrowserState
    @State private var sourceCode = ""
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var showLineNumbers = true
    @State private var wordWrap = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                TextField("Search in source...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                
                Toggle("Lines", isOn: $showLineNumbers)
                    .toggleStyle(.button)
                    .font(.caption)
                
                Toggle("Wrap", isOn: $wordWrap)
                    .toggleStyle(.button)
                    .font(.caption)
                
                Button(action: copySource) {
                    Label("Copy", systemImage: "doc.on.doc")
                        .labelStyle(.iconOnly)
                }
                
                Button(action: refreshSource) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                        .labelStyle(.iconOnly)
                }
            }
            .padding()
            
            Divider()
            
            // Source code view
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading source...")
                    Spacer()
                }
            } else if sourceCode.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "doc.text")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No source code available")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ScrollView([.horizontal, .vertical]) {
                    SourceCodeView(
                        code: highlightedSource,
                        showLineNumbers: showLineNumbers,
                        wordWrap: wordWrap
                    )
                    .padding()
                }
            }
        }
        .task {
            await loadSource()
        }
    }
    
    private var highlightedSource: String {
        // Basic syntax highlighting - in a real implementation, use a proper syntax highlighter
        var highlighted = sourceCode
        
        if !searchText.isEmpty {
            highlighted = highlighted.replacingOccurrences(
                of: searchText,
                with: "**\(searchText)**",
                options: .caseInsensitive
            )
        }
        
        return highlighted
    }
    
    private func loadSource() async {
        isLoading = true
        
        // In a real implementation, fetch HTML from active tab's webview
        // For now, use placeholder
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        sourceCode = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Example Page</title>
        </head>
        <body>
            <h1>Hello World</h1>
            <p>This is sample page source.</p>
        </body>
        </html>
        """
        
        isLoading = false
    }
    
    private func refreshSource() {
        Task {
            await loadSource()
        }
    }
    
    private func copySource() {
        #if os(iOS)
        UIPasteboard.general.string = sourceCode
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(sourceCode, forType: .string)
        #endif
    }
}

struct SourceCodeView: View {
    let code: String
    let showLineNumbers: Bool
    let wordWrap: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if showLineNumbers {
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(Array(code.components(separatedBy: "\n").enumerated()), id: \.offset) { index, _ in
                        Text("\(index + 1)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.secondary)
                            .frame(minWidth: 30, alignment: .trailing)
                    }
                }
            }
            
            Text(code)
                .font(.system(.caption, design: .monospaced))
                .textSelection(.enabled)
                .lineLimit(wordWrap ? nil : .max)
        }
    }
}
