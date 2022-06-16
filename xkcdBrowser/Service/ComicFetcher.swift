import Foundation

protocol ComicDownloader {
    func downloadComicInfo(from url: URL) async throws -> XKCDComic
}

struct ComicFetcher: ComicDownloader {
    
    private let decoder = JSONDecoder()
    
    func downloadComicInfo(from url: URL) async throws -> XKCDComic {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.serverError
        }
        
        do {
            let comics = try decoder.decode(XKCDComic.self, from: data)
            return comics
        } catch {
            throw NetworkError.parseJSONError
        }
    }
}

enum ComicsEndpoint {
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


struct MockComicsFetcher: ComicDownloader {
    func downloadComicInfo(from url: URL) async throws -> XKCDComic {
        let comics = XKCDComic(
            id: 614,
            text: "If you don't have an extension cord I can get that too.  Because we're friends!  Right?",
            imageUrl: URL(string: "https://imgs.xkcd.com/comics/woodpecker.png")!,
            title: "Woodpecker")
        return comics
    }
}
