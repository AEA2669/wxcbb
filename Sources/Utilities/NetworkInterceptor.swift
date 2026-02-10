import Foundation

class NetworkInterceptor: URLProtocol {
    static var requestHandler: ((URLRequest) -> (URLResponse, Data)?)?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let handler = NetworkInterceptor.requestHandler,
           let (response, data) = handler(request) {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } else {
            // Continue with normal request
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.client?.urlProtocol(self, didFailWithError: error)
                    return
                }
                
                if let response = response {
                    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                
                if let data = data {
                    self.client?.urlProtocol(self, didLoad: data)
                }
                
                self.client?.urlProtocolDidFinishLoading(self)
            }
            task.resume()
        }
    }
    
    override func stopLoading() {
        // Stop loading
    }
}
