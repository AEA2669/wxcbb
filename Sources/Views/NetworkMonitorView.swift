import SwiftUI

struct NetworkMonitorView: View {
    @EnvironmentObject var browserState: BrowserState
    @State private var searchText = ""
    @State private var selectedFilter: RequestFilter = .all
    @State private var selectedRequest: NetworkRequest?
    
    enum RequestFilter: String, CaseIterable {
        case all = "All"
        case xhr = "XHR"
        case fetch = "Fetch"
        case doc = "Doc"
        case css = "CSS"
        case js = "JS"
        case image = "Image"
        case font = "Font"
        case other = "Other"
    }
    
    var filteredRequests: [NetworkRequest] {
        var requests = browserState.networkRequests
        
        // Apply search filter
        if !searchText.isEmpty {
            requests = requests.filter { $0.url.absoluteString.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Apply type filter
        if selectedFilter != .all {
            requests = requests.filter { $0.type.rawValue.lowercased() == selectedFilter.rawValue.lowercased() }
        }
        
        return requests.reversed()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and filters
            HStack {
                TextField("Search requests...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: { browserState.clearNetworkRequests() }) {
                    Label("Clear", systemImage: "trash")
                        .labelStyle(.iconOnly)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Filter buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(RequestFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // Request list
            if filteredRequests.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "network")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No network requests")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                List(filteredRequests) { request in
                    NetworkRequestRow(request: request)
                        .onTapGesture {
                            selectedRequest = request
                        }
                }
                .listStyle(.plain)
            }
        }
        .sheet(item: $selectedRequest) { request in
            NetworkRequestDetailView(request: request)
        }
    }
}

struct NetworkRequestRow: View {
    let request: NetworkRequest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // Method badge
                Text(request.method.rawValue)
                    .font(.caption2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(methodColor)
                    .cornerRadius(4)
                
                // Status code
                if let status = request.statusCode {
                    Text("\(status)")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(statusColor)
                        .cornerRadius(4)
                }
                
                // Type badge
                Text(request.type.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Duration
                if let duration = request.duration {
                    Text("\(Int(duration))ms")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(request.url.absoluteString)
                .font(.caption)
                .lineLimit(1)
            
            Text(formatTimestamp(request.timestamp))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var methodColor: Color {
        switch request.method {
        case .GET: return .blue
        case .POST: return .green
        case .PUT: return .orange
        case .DELETE: return .red
        case .PATCH: return .purple
        default: return .gray
        }
    }
    
    private var statusColor: Color {
        guard let code = request.statusCode else { return .gray }
        switch code {
        case 200..<300: return .green
        case 300..<400: return .yellow
        case 400..<500: return .orange
        case 500..<600: return .red
        default: return .gray
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

struct NetworkRequestDetailView: View {
    let request: NetworkRequest
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("General") {
                    DetailRow(label: "URL", value: request.url.absoluteString)
                    DetailRow(label: "Method", value: request.method.rawValue)
                    if let status = request.statusCode {
                        DetailRow(label: "Status", value: "\(status)")
                    }
                    if let duration = request.duration {
                        DetailRow(label: "Duration", value: "\(Int(duration))ms")
                    }
                    DetailRow(label: "Type", value: request.type.rawValue)
                }
                
                if let requestBody = request.requestBody {
                    Section("Request Body") {
                        Text(requestBody)
                            .font(.caption)
                            .textSelection(.enabled)
                    }
                }
                
                if let responseBody = request.responseBody {
                    Section("Response Body") {
                        Text(responseBody)
                            .font(.caption)
                            .textSelection(.enabled)
                    }
                }
            }
            .navigationTitle("Request Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor : Color(uiColor: .secondarySystemBackground))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .textSelection(.enabled)
        }
    }
}
