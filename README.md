# 🌐 DevBrowser - Developer Browser for Swift Playgrounds

A fully-featured, modern web browser with powerful developer tools built entirely in Swift for iPad and Mac using Swift Playgrounds.

![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2017%20|%20macOS%2014-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## ✨ Features

### 🌐 Core Browsing
- **Smart URL Bar** with auto-complete and search engine fallback
- **Navigation Controls**: Back, Forward, Refresh, Stop, Home
- **Multi-Tab Management**: Create, close, and switch between tabs with favicon + title
- **Bookmarks**: Save, edit, delete, and organize your favorite sites
- **Pull-to-Refresh** gesture support for easy page reloading
- **Progress Indicator** showing real-time page load progress
- **Swipe Gestures**: Navigate back/forward with natural swipe gestures

### 🔗 Link Capture & Viewer
- Automatically extracts all hyperlinks from loaded pages
- Searchable, filterable list of all links
- Distinguishes between internal and external links
- Copy, share, or open links in new tabs
- Export complete link list
- Live badge showing total link count

### 🖼️ Image Capture & Gallery
- Extracts all images from pages (IMG tags, CSS backgrounds, Picture elements, Srcset)
- Beautiful gallery grid view with customizable columns
- Tap to view full-size with zoom and pan
- Image metadata: dimensions, file size, alt text, source URL
- Save images to photo library (with permission)
- Filter and search images

### 📡 Network Monitor
- Intercepts and logs all network requests (XHR, Fetch API, WebSocket)
- Detailed request information:
  - HTTP method with color coding
  - Status codes (color coded: green 2xx, yellow 3xx, red 4xx/5xx)
  - Response time and duration
  - Request/Response headers
  - Request/Response body with JSON pretty-printing
  - Content type detection
- Filter by request type (XHR, Fetch, WebSocket, Document, CSS, JS, Image, Font)
- Search requests by URL
- Export HAR-like data
- Clear log functionality

### 🛠️ JavaScript Console
- Interactive JavaScript REPL - execute code in page context
- Captures console.log, console.warn, console.error, console.info
- Color-coded log levels for easy identification
- Command history for quick re-execution
- Auto-complete for common JavaScript methods
- Clear console button
- Timestamps for all messages

### 📄 Page Source Viewer
- View complete HTML source of current page
- Syntax highlighting for HTML (tags, attributes, values, comments)
- Line numbers toggle
- Search within source code
- Copy entire source to clipboard
- Word wrap toggle for better readability

### 🎨 Modern UI/UX
- **Dark Mode** support (auto, light, dark)
- **SF Symbols** for all icons
- Smooth animations and transitions
- **Split View**: browser and dev tools with resizable panels
- **Bottom Toolbar** with quick access to all developer tools
- Glassmorphism/material effects throughout
- Haptic feedback on interactions
- Responsive layout for iPad and Mac

### ⚙️ Settings & Privacy
- Search engine selection (Google, DuckDuckGo, Bing)
- Clear browsing data (history, cookies, cache)
- Toggle JavaScript on/off
- Custom User-Agent string
- Desktop/Mobile mode toggle
- Block popups toggle
- Theme selection (System, Light, Dark)

## 📸 Screenshots

_Screenshots will be added here_

## 🚀 Getting Started

### Requirements
- iOS 17+ / macOS 14+
- Swift Playgrounds 4.0+ or Xcode 15+

### Opening in Swift Playgrounds

1. Clone or download this repository
2. Open the folder in Swift Playgrounds on iPad or Mac
3. Tap/Click the ▶️ Run button to launch the app

### Opening in Xcode

1. Open `Package.swift` in Xcode 15+
2. Select a simulator or device
3. Build and run (⌘R)

## 🏗️ Technical Architecture

### Project Structure

```
DevBrowser/
├── Package.swift                    # Swift Package Manager configuration
├── Sources/
│   ├── DevBrowserApp.swift         # App entry point & state management
│   ├── ContentView.swift           # Main app layout & coordination
│   ├── Models/
│   │   ├── Tab.swift               # Tab data model
│   │   ├── NetworkRequest.swift    # Network request capture model
│   │   ├── CapturedLink.swift      # Link capture model
│   │   └── CapturedImage.swift     # Image capture model
│   ├── Views/
│   │   ├── BrowserView.swift       # Core browser UI (URL bar, navigation)
│   │   ├── TabBarView.swift        # Tab management interface
│   │   ├── NetworkMonitorView.swift # Network request viewer
│   │   ├── LinkCaptureView.swift   # Link extraction & display
│   │   ├── ImageCaptureView.swift  # Image gallery & viewer
│   │   ├── JavaScriptConsoleView.swift # JS console
│   │   ├── PageSourceView.swift    # HTML source viewer
│   │   ├── BookmarksView.swift     # Bookmark manager
│   │   └── SettingsView.swift      # Settings & preferences
│   ├── WebView/
│   │   ├── WebViewRepresentable.swift  # WKWebView SwiftUI wrapper
│   │   ├── WebViewCoordinator.swift    # WKWebView delegate & handlers
│   │   └── UserScripts.swift           # JavaScript injection scripts
│   └── Utilities/
│       ├── NetworkInterceptor.swift    # URL protocol interception
│       └── Theme.swift                 # Theme & styling utilities
└── README.md
```

### Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **WKWebView**: WebKit browsing engine
- **Combine**: Reactive data flow
- **@Observable**: Modern state management
- **JavaScript Injection**: WKUserScript for page interaction
- **WKScriptMessageHandler**: Bidirectional Swift ↔ JavaScript communication

### JavaScript Injection

The app injects JavaScript into every loaded page to capture:

1. **Links**: Extracts all `<a>` tags with text and URLs
2. **Images**: Finds all images including CSS backgrounds and srcset
3. **Network Requests**: Monkey-patches XMLHttpRequest, fetch(), and WebSocket
4. **Console Messages**: Intercepts console.log/info/warn/error

All captured data is sent back to Swift via `window.webkit.messageHandlers`.

## 🔒 Privacy & Security

- No data is sent to external servers
- All browsing data stays on your device
- Clear browsing data anytime from Settings
- JavaScript injection only monitors; doesn't modify page behavior
- Popup blocking enabled by default

## 🛠️ Development

### Building from Source

```bash
# Clone the repository
git clone https://github.com/AEA2669/browser-transfer.git
cd browser-transfer

# Open in Xcode
open Package.swift

# Or use Swift Playgrounds
# Just open the folder in Swift Playgrounds app
```

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is licensed under the MIT License - see below for details:

```
MIT License

Copyright (c) 2024 DevBrowser

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🙏 Acknowledgments

- Built with ❤️ using Swift and SwiftUI
- Powered by WebKit
- Icons from SF Symbols

## 📧 Contact

For questions, feedback, or issues, please open an issue on GitHub.

---

**Made with Swift Playgrounds** 🚀
