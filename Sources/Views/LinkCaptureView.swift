import SwiftUI

struct LinkCaptureView: View {
    @EnvironmentObject var browserState: BrowserState
    @State private var searchText = ""
    @State private var filterExternal = false
    
    var activeTab: Tab? {
        browserState.activeTab
    }
    
    var filteredLinks: [CapturedLink] {
        guard let tab = activeTab else { return [] }
        var links = tab.capturedLinks
        
        if !searchText.isEmpty {
            links = links.filter {
                $0.text.localizedCaseInsensitiveContains(searchText) ||
                $0.url.absoluteString.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if filterExternal {
            links = links.filter { $0.isExternal }
        }
        
        return links
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar and filters
            HStack {
                TextField("Search links...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                
                Toggle("External", isOn: $filterExternal)
                    .toggleStyle(.button)
                    .font(.caption)
                
                Button(action: exportLinks) {
                    Label("Export", systemImage: "square.and.arrow.up")
                        .labelStyle(.iconOnly)
                }
            }
            .padding()
            
            Divider()
            
            // Stats
            HStack {
                Label("\(filteredLinks.count)", systemImage: "link")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let tab = activeTab {
                    Label("\(tab.capturedLinks.filter { $0.isExternal }.count) external",
                          systemImage: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Links list
            if filteredLinks.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "link.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No links found")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                List(filteredLinks) { link in
                    LinkRow(link: link)
                }
                .listStyle(.plain)
            }
        }
    }
    
    private func exportLinks() {
        let linksText = filteredLinks.map { "\($0.text)\n\($0.url.absoluteString)\n" }.joined(separator: "\n")
        
        #if os(iOS)
        UIPasteboard.general.string = linksText
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(linksText, forType: .string)
        #endif
    }
}

struct LinkRow: View {
    let link: CapturedLink
    @State private var showCopyConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(link.text)
                    .font(.body)
                    .lineLimit(2)
                
                Spacer()
                
                if link.isExternal {
                    Image(systemName: "arrow.up.right.square")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            Text(link.url.absoluteString)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .contextMenu {
            Button(action: copyURL) {
                Label("Copy URL", systemImage: "doc.on.doc")
            }
            
            Button(action: {}) {
                Label("Open in New Tab", systemImage: "plus.square.on.square")
            }
        }
        .overlay(
            Group {
                if showCopyConfirmation {
                    Text("Copied!")
                        .font(.caption)
                        .padding(4)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
        )
    }
    
    private func copyURL() {
        #if os(iOS)
        UIPasteboard.general.string = link.url.absoluteString
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(link.url.absoluteString, forType: .string)
        #endif
        
        showCopyConfirmation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            showCopyConfirmation = false
        }
    }
}
