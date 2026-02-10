import SwiftUI

struct JavaScriptConsoleView: View {
    @EnvironmentObject var browserState: BrowserState
    @State private var commandText = ""
    @State private var commandHistory: [String] = []
    @State private var historyIndex = -1
    
    var body: some View {
        VStack(spacing: 0) {
            // Console output
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(browserState.consoleMessages) { message in
                            ConsoleMessageRow(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: browserState.consoleMessages.count) { _, _ in
                    if let lastMessage = browserState.consoleMessages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // Command input
            HStack {
                TextField("Type JavaScript command...", text: $commandText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        executeCommand()
                    }
                
                Button(action: executeCommand) {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(commandText.isEmpty)
                
                Button(action: { browserState.clearConsole() }) {
                    Image(systemName: "trash")
                }
            }
            .padding()
            .background(Theme.secondarySystemBackground)
        }
    }
    
    private func executeCommand() {
        let command = commandText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !command.isEmpty else { return }
        
        // Add to history
        commandHistory.append(command)
        historyIndex = commandHistory.count
        
        // Add to console as log
        let message = ConsoleMessage(type: .log, message: "> \(command)")
        browserState.addConsoleMessage(message)
        
        // Execute in WebView (would need to pass to active tab's webview)
        // For now, just clear the input
        commandText = ""
    }
}

struct ConsoleMessageRow: View {
    let message: ConsoleMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: message.type.icon)
                .font(.caption)
                .foregroundColor(message.type.color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(message.message)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(message.type.color)
                    .textSelection(.enabled)
                
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}
