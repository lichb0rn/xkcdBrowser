import Foundation

protocol Networking {
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension Networking {
    func data(from url: URL, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        return try await data(from: url, delegate: delegate)
    }
}

extension URLSession: Networking {}
