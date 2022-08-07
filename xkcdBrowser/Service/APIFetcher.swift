import Foundation

protocol Fetching {
    func downloadItem<T: Decodable>(fromURL url: URL, ofType model: T.Type) async throws -> T
    func downloadItems<T: Decodable>(fromURLs urls: [URL], ofType model: T.Type) async throws -> [T]
}


struct APIFetcher: Fetching {
    
    /// Download a single item of type `T`
    func downloadItem<T: Decodable>(fromURL url: URL, ofType model: T.Type) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode <= 299 else {
            throw NetworkError.badServerResponse
        }
        
        do {
            let decoded = try JSONDecoder().decode(model, from: data)
            return decoded
        } catch {
            throw NetworkError.parseJSONError
        }
    }
    
    /// Download and array of items of type `T`
    func downloadItems<T: Decodable>(fromURLs urls: [URL], ofType model: T.Type) async throws -> [T] {
        guard !urls.isEmpty else { return [] }
    
        return try await withThrowingTaskGroup(of: model, body: { group -> [T] in
            var items: [T] = []
            
            urls.forEach { url in
                group.addTask(priority: .background) {
                    try await self.downloadItem(fromURL: url, ofType: model)
                }
            }
            
            for try await item in group {
                items.append(item)
            }
            return items
        })
    }
}
