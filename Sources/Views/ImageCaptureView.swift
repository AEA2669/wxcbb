import SwiftUI

struct ImageCaptureView: View {
    @EnvironmentObject var browserState: BrowserState
    @State private var searchText = ""
    @State private var selectedImage: CapturedImage?
    @State private var gridColumns = 3
    
    var activeTab: Tab? {
        browserState.activeTab
    }
    
    var filteredImages: [CapturedImage] {
        guard let tab = activeTab else { return [] }
        var images = tab.capturedImages
        
        if !searchText.isEmpty {
            images = images.filter {
                $0.url.absoluteString.localizedCaseInsensitiveContains(searchText) ||
                ($0.alt?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return images
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                TextField("Search images...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                
                Picker("Columns", selection: $gridColumns) {
                    Text("2").tag(2)
                    Text("3").tag(3)
                    Text("4").tag(4)
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }
            .padding()
            
            Divider()
            
            // Stats
            HStack {
                Label("\(filteredImages.count) images", systemImage: "photo")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Image grid
            if filteredImages.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "photo.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No images found")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: gridColumns), spacing: 8) {
                        ForEach(filteredImages) { image in
                            ImageThumbnail(image: image)
                                .onTapGesture {
                                    selectedImage = image
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(item: $selectedImage) { image in
            ImageDetailView(image: image)
        }
    }
}

struct ImageThumbnail: View {
    let image: CapturedImage
    @State private var loadedImage: Image?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if let loadedImage = loadedImage {
                loadedImage
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                ProgressView()
            } else {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 100)
        .background(Theme.secondarySystemBackground)
        .cornerRadius(8)
        .clipped()
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: image.url)
            
            #if os(iOS)
            if let uiImage = UIImage(data: data) {
                loadedImage = Image(uiImage: uiImage)
            }
            #elseif os(macOS)
            if let nsImage = NSImage(data: data) {
                loadedImage = Image(nsImage: nsImage)
            }
            #endif
            
            isLoading = false
        } catch {
            isLoading = false
        }
    }
}

struct ImageDetailView: View {
    let image: CapturedImage
    @Environment(\.dismiss) var dismiss
    @State private var loadedImage: Image?
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack {
                if let loadedImage = loadedImage {
                    ScrollView([.horizontal, .vertical]) {
                        loadedImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                } else if isLoading {
                    ProgressView("Loading...")
                } else {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                        Text("Failed to load image")
                    }
                    .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Image info
                List {
                    DetailRow(label: "URL", value: image.url.absoluteString)
                    if let alt = image.alt {
                        DetailRow(label: "Alt Text", value: alt)
                    }
                    if let width = image.width, let height = image.height {
                        DetailRow(label: "Dimensions", value: "\(width) × \(height)")
                    }
                    DetailRow(label: "Source", value: image.source.rawValue)
                }
                .frame(height: 200)
            }
            .navigationTitle("Image Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveImage) {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                }
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: image.url)
            
            #if os(iOS)
            if let uiImage = UIImage(data: data) {
                loadedImage = Image(uiImage: uiImage)
            }
            #elseif os(macOS)
            if let nsImage = NSImage(data: data) {
                loadedImage = Image(nsImage: nsImage)
            }
            #endif
            
            isLoading = false
        } catch {
            isLoading = false
        }
    }
    
    private func saveImage() {
        // Placeholder for save functionality
        // Would require photo library permissions
    }
}
