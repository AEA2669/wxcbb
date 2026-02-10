import Foundation

struct UserScripts {
    // MARK: - Link Capture Script
    
    static let linkCaptureScript = """
    function captureLinkData() {
        var links = [];
        var anchors = document.getElementsByTagName('a');
        var currentHost = window.location.hostname;
        
        for (var i = 0; i < anchors.length; i++) {
            var anchor = anchors[i];
            var href = anchor.href;
            var text = anchor.textContent.trim() || anchor.title || href;
            
            if (href && href !== '' && href !== '#') {
                try {
                    var linkHost = new URL(href).hostname;
                    var isExternal = linkHost !== currentHost && linkHost !== '';
                    
                    links.push({
                        url: href,
                        text: text.substring(0, 200),
                        external: isExternal
                    });
                } catch(e) {}
            }
        }
        
        window.webkit.messageHandlers.linkCapture.postMessage(links);
    }
    
    // Auto-capture links when page loads
    if (document.readyState === 'complete') {
        captureLinkData();
    } else {
        window.addEventListener('load', captureLinkData);
    }
    """
    
    // MARK: - Image Capture Script
    
    static let imageCaptureScript = """
    function captureImageData() {
        var images = [];
        
        // Capture <img> tags
        var imgTags = document.getElementsByTagName('img');
        for (var i = 0; i < imgTags.length; i++) {
            var img = imgTags[i];
            if (img.src && img.src !== '') {
                images.push({
                    url: img.src,
                    alt: img.alt || null,
                    width: img.naturalWidth || img.width || null,
                    height: img.naturalHeight || img.height || null,
                    source: 'IMG Tag'
                });
            }
            
            // Check srcset
            if (img.srcset) {
                var srcsetParts = img.srcset.split(',');
                for (var j = 0; j < srcsetParts.length; j++) {
                    var srcUrl = srcsetParts[j].trim().split(' ')[0];
                    if (srcUrl) {
                        images.push({
                            url: srcUrl,
                            alt: img.alt || null,
                            width: null,
                            height: null,
                            source: 'Srcset'
                        });
                    }
                }
            }
        }
        
        // Capture <picture> elements
        var pictureTags = document.getElementsByTagName('picture');
        for (var i = 0; i < pictureTags.length; i++) {
            var sources = pictureTags[i].getElementsByTagName('source');
            for (var j = 0; j < sources.length; j++) {
                if (sources[j].srcset) {
                    var srcsetParts = sources[j].srcset.split(',');
                    for (var k = 0; k < srcsetParts.length; k++) {
                        var srcUrl = srcsetParts[k].trim().split(' ')[0];
                        if (srcUrl) {
                            images.push({
                                url: srcUrl,
                                alt: null,
                                width: null,
                                height: null,
                                source: 'Picture Element'
                            });
                        }
                    }
                }
            }
        }
        
        // Capture CSS background images
        var allElements = document.querySelectorAll('*');
        for (var i = 0; i < allElements.length; i++) {
            var style = window.getComputedStyle(allElements[i]);
            var bgImage = style.backgroundImage;
            if (bgImage && bgImage !== 'none') {
                var urlMatch = bgImage.match(/url\\(['"]?(.*?)['"]?\\)/);
                if (urlMatch && urlMatch[1]) {
                    var imageUrl = urlMatch[1];
                    if (imageUrl.startsWith('http') || imageUrl.startsWith('//') || imageUrl.startsWith('/')) {
                        images.push({
                            url: new URL(imageUrl, window.location.href).href,
                            alt: null,
                            width: null,
                            height: null,
                            source: 'CSS Background'
                        });
                    }
                }
            }
        }
        
        // Remove duplicates
        var uniqueImages = [];
        var urls = new Set();
        for (var i = 0; i < images.length; i++) {
            if (!urls.has(images[i].url)) {
                urls.add(images[i].url);
                uniqueImages.push(images[i]);
            }
        }
        
        window.webkit.messageHandlers.imageCapture.postMessage(uniqueImages);
    }
    
    // Auto-capture images when page loads
    if (document.readyState === 'complete') {
        captureImageData();
    } else {
        window.addEventListener('load', captureImageData);
    }
    """
    
    // MARK: - Network Capture Script
    
    static let networkCaptureScript = """
    (function() {
        // Intercept XMLHttpRequest
        var originalXHROpen = XMLHttpRequest.prototype.open;
        var originalXHRSend = XMLHttpRequest.prototype.send;
        
        XMLHttpRequest.prototype.open = function(method, url) {
            this._method = method;
            this._url = url;
            this._startTime = Date.now();
            return originalXHROpen.apply(this, arguments);
        };
        
        XMLHttpRequest.prototype.send = function(body) {
            var xhr = this;
            
            xhr.addEventListener('loadend', function() {
                var duration = Date.now() - xhr._startTime;
                
                try {
                    window.webkit.messageHandlers.networkCapture.postMessage({
                        type: 'xhr',
                        method: xhr._method,
                        url: xhr._url,
                        status: xhr.status,
                        duration: duration,
                        contentType: xhr.getResponseHeader('Content-Type'),
                        requestBody: body ? String(body) : null,
                        responseBody: xhr.responseText ? xhr.responseText.substring(0, 10000) : null
                    });
                } catch(e) {}
            });
            
            return originalXHRSend.apply(this, arguments);
        };
        
        // Intercept Fetch API
        var originalFetch = window.fetch;
        window.fetch = function() {
            var startTime = Date.now();
            var url = arguments[0];
            var options = arguments[1] || {};
            var method = options.method || 'GET';
            
            return originalFetch.apply(this, arguments).then(function(response) {
                var duration = Date.now() - startTime;
                
                var clonedResponse = response.clone();
                clonedResponse.text().then(function(body) {
                    try {
                        window.webkit.messageHandlers.networkCapture.postMessage({
                            type: 'fetch',
                            method: method,
                            url: url,
                            status: response.status,
                            duration: duration,
                            contentType: response.headers.get('Content-Type'),
                            requestBody: options.body ? String(options.body) : null,
                            responseBody: body ? body.substring(0, 10000) : null
                        });
                    } catch(e) {}
                });
                
                return response;
            });
        };
        
        // Intercept WebSocket
        var originalWebSocket = window.WebSocket;
        window.WebSocket = function() {
            var ws = new originalWebSocket(...arguments);
            var url = arguments[0];
            
            try {
                window.webkit.messageHandlers.networkCapture.postMessage({
                    type: 'websocket',
                    method: 'WS',
                    url: url,
                    status: null,
                    duration: 0,
                    contentType: 'websocket',
                    requestBody: null,
                    responseBody: null
                });
            } catch(e) {}
            
            return ws;
        };
    })();
    """
    
    // MARK: - Console Capture Script
    
    static let consoleCaptureScript = """
    (function() {
        var originalLog = console.log;
        var originalInfo = console.info;
        var originalWarn = console.warn;
        var originalError = console.error;
        
        function sendToNative(type, args) {
            try {
                var message = Array.prototype.slice.call(args).map(function(arg) {
                    if (typeof arg === 'object') {
                        return JSON.stringify(arg, null, 2);
                    }
                    return String(arg);
                }).join(' ');
                
                window.webkit.messageHandlers.consoleCapture.postMessage({
                    type: type,
                    message: message
                });
            } catch(e) {}
        }
        
        console.log = function() {
            sendToNative('log', arguments);
            return originalLog.apply(console, arguments);
        };
        
        console.info = function() {
            sendToNative('info', arguments);
            return originalInfo.apply(console, arguments);
        };
        
        console.warn = function() {
            sendToNative('warn', arguments);
            return originalWarn.apply(console, arguments);
        };
        
        console.error = function() {
            sendToNative('error', arguments);
            return originalError.apply(console, arguments);
        };
    })();
    """
}
