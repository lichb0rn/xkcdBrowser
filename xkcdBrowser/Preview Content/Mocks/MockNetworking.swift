import Foundation

class MockNetworking: Networking {
    
    var result: Result<Data, Error> = .success(Data())
    
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        
        var response: HTTPURLResponse
        switch result {
        case .success:
            response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return try (result.get(), response)
        case .failure:
            response = HTTPURLResponse(url: url, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return try (result.get(), response)
        }
        
    }
}
