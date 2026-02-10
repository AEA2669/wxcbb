import SwiftUI

struct TabBarView: View {
    @EnvironmentObject var browserState: BrowserState
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Tabs")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    browserState.addNewTab()
                    isPresented = false
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Tab grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                    ForEach(Array(browserState.tabs.enumerated()), id: \.element.id) { index, tab in
                        TabCard(tab: tab, isActive: index == browserState.activeTabIndex)
                            .onTapGesture {
                                browserState.activeTabIndex = index
                                isPresented = false
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    browserState.closeTab(at: index)
                                    if browserState.tabs.isEmpty {
                                        isPresented = false
                                    }
                                } label: {
                                    Label("Close Tab", systemImage: "xmark")
                                }
                            }
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 500)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}

struct TabCard: View {
    let tab: Tab
    let isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let favicon = tab.favicon {
                    Image(systemName: favicon)
                        .font(.caption)
                } else {
                    Image(systemName: "globe")
                        .font(.caption)
                }
                
                Text(tab.title)
                    .font(.caption)
                    .lineLimit(1)
                
                Spacer()
            }
            
            if let url = tab.url {
                Text(url.host ?? url.absoluteString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 80)
                .overlay(
                    Image(systemName: "doc.text")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                )
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isActive ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }
}
