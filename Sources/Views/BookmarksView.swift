import SwiftUI

struct BookmarksView: View {
    @EnvironmentObject var browserState: BrowserState
    @Binding var isPresented: Bool
    @State private var searchText = ""
    @State private var editingBookmark: Bookmark?
    
    var filteredBookmarks: [Bookmark] {
        if searchText.isEmpty {
            return browserState.bookmarks
        }
        return browserState.bookmarks.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.url.absoluteString.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Bookmarks")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Search bar
            HStack {
                TextField("Search bookmarks...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            
            // Bookmarks list
            if filteredBookmarks.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "bookmark")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text(searchText.isEmpty ? "No bookmarks yet" : "No matching bookmarks")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                List {
                    ForEach(filteredBookmarks) { bookmark in
                        BookmarkRow(bookmark: bookmark)
                            .onTapGesture {
                                openBookmark(bookmark)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteBookmark(bookmark)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    editingBookmark = bookmark
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 600)
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
        .sheet(item: $editingBookmark) { bookmark in
            EditBookmarkView(bookmark: bookmark)
        }
    }
    
    private func openBookmark(_ bookmark: Bookmark) {
        if let tab = browserState.activeTab {
            var updatedTab = tab
            updatedTab.url = bookmark.url
            // Update the tab in browserState
        }
        isPresented = false
    }
    
    private func deleteBookmark(_ bookmark: Bookmark) {
        if let index = browserState.bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
            browserState.removeBookmark(at: index)
        }
    }
}

struct BookmarkRow: View {
    let bookmark: Bookmark
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(bookmark.title)
                .font(.body)
            
            Text(bookmark.url.absoluteString)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

struct EditBookmarkView: View {
    @EnvironmentObject var browserState: BrowserState
    @Environment(\.dismiss) var dismiss
    let bookmark: Bookmark
    
    @State private var title: String
    @State private var urlString: String
    
    init(bookmark: Bookmark) {
        self.bookmark = bookmark
        _title = State(initialValue: bookmark.title)
        _urlString = State(initialValue: bookmark.url.absoluteString)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Title") {
                    TextField("Bookmark title", text: $title)
                }
                
                Section("URL") {
                    TextField("URL", text: $urlString)
                        .autocapitalization(.none)
                        .keyboardType(.URL)
                }
            }
            .navigationTitle("Edit Bookmark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        guard let url = URL(string: urlString),
              let index = browserState.bookmarks.firstIndex(where: { $0.id == bookmark.id }) else {
            return
        }
        
        var updatedBookmark = bookmark
        updatedBookmark.title = title
        updatedBookmark.url = url
        
        browserState.bookmarks[index] = updatedBookmark
    }
}
