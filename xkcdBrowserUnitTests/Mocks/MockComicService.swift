import Foundation
@testable import xkcdBrowser

actor MockComicService: ComicDataSource {
    
    var data: [Comic] = []
    let preview = PreviewData()
    var error: Bool = false
    
    func store(comic: Comic, forKey: URL) async {
        data.append(comic)
    }
    
    func comic(_ url: URL) async throws -> Comic {
        guard !error else {
            throw NetworkError.badServerResponse
        }

        if let comic = data.first(where: { $0.comicURL == url }) {
            return comic
        } else {
            return data.last!
        }
    }
    
    func comics(_ urls: [URL]) async throws -> [Comic] {
        guard !error else {
            throw NetworkError.badServerResponse
        }
        
        return data
    }
    
    func clear() async {
        data.removeAll()
    }
    
    func shouldThrow() {
        error = true
    }
}
