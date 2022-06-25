import Foundation

protocol ComicDownloader {
    func fetchComicItem(withIndex index: Int) async throws -> ComicItem
}

struct ComicFetcher: ComicDownloader {
    
    private let imageService: ImageDownloader = ImageService.shared
    private let decoder = JSONDecoder()
    
    
    /// Fetch ComicItem from server
    /// - Parameter index: Optional xkcd comic index (num). If not provided, fetches the most recent comic.
    /// - Returns: ComicItem
    func fetchComicItem(withIndex index: Int = 0) async throws -> ComicItem {
        var url: URL
        if index > 0 {
            url = ComicEndpoint.version(number: index).url
        } else {
            url = ComicEndpoint.current.url
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.serverError
        }
        do {
            let comicData = try decoder.decode(XKCDComic.self, from: data)
            return ComicItem(downloader: imageService, comicData: comicData)
        } catch {
            throw NetworkError.parseJSONError
        }
    }
}

enum ComicEndpoint {
    private var baseURL: String { "https://xkcd.com/" }
    private var suffix: String { "info.0.json" }
    
    case current
    case version(number: Int)
    
    var url: URL {
        guard let url = URL(string: baseURL) else { preconditionFailure("Not valid baseURL") }
        switch self {
        case .current:
            return url.appendingPathComponent(suffix)
        case .version(let number):
            return url.appendingPathComponent("\(number)/\(suffix)")
        }
    }
}
