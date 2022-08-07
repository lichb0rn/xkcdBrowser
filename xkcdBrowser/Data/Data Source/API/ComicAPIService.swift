import Foundation


enum APIServiceError: Error {
    case badURL
    case requestError
    case badServerResponse
    case decodingError
}

struct ComicAPIService: ComicDataSource {
    
    
    /// Download comics from API
    /// - Throws:
    ///     - `APIServiceError.badServerResponse`
    ///         if server startus code from response is anything except `200..<300>`
    ///     - `APIServiceError.decodingError`
    ///         if received invalid JSON from the service
    /// - Parameters:
    ///   - index: start index, specify `-1` to get the latest
    ///   - count: fetch count
    /// - Returns: Array of Comics
    func getComics(fromIndex index: Int, count: Int) async throws -> [Comic] {
        return []
    }
    
    func getComic(withIndex index: Int) async throws -> Comic? {
        return nil
    }
}

extension ComicAPIService: Fetching {
    
}
