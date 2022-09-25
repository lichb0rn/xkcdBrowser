import Foundation

protocol Fetching {
    func downloadItem(fromURL url: URL) async throws -> Data
    
    func downloadItem<T: Decodable>(fromURL url: URL, ofType model: T.Type) async throws -> T
    func downloadItems<T: Decodable>(fromURLs urls: [URL], ofType model: T.Type) async throws -> [T]
}

enum NetworkError: Error {
    case badURL
    case requestError
    case badServerResponse
    case decodingError
}

struct Fetcher: Fetching {
    private let networking: Networking
    
    init(networking: Networking = URLSession.shared) {
        self.networking = networking
    }
    
    // For images. Probably should refactor other methods to return Data
    func downloadItem(fromURL url: URL) async throws -> Data {
        let (data, response) = try await networking.data(from: url)
        guard let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode <= 299 else {
            throw NetworkError.badServerResponse
        }
        return data
    }
    
    func downloadItem<T: Decodable>(fromURL url: URL, ofType model: T.Type) async throws -> T {
        let (data, response) = try await networking.data(from: url)
        guard let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode <= 299 else {
            throw NetworkError.badServerResponse
        }
        
        do {
            let decoded = try JSONDecoder().decode(model, from: data)
            return decoded
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func downloadItems<T: Decodable>(fromURLs urls: [URL], ofType model: T.Type) async throws -> [T] {
        guard !urls.isEmpty else { return [] }
        
        let results = try await withThrowingTaskGroup(of: model) { group in
            
            urls.forEach { url in
                group.addTask(priority: .userInitiated) {
                    return try await self.downloadItem(fromURL: url, ofType: model)
                }
            }
            
            var items: [T] = []
            items.reserveCapacity(urls.count)

            for try await item in group.compactMap({$0}) {
                items.append(item)
            }
            return items
        }

        return results
    }
}
