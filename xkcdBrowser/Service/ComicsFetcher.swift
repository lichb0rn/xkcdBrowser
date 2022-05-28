import Foundation

protocol ComicsDownloader {
    func downloadComicsInfo(from url: URL) async throws -> XKCDComics
}

struct ComicsFetcher: ComicsDownloader {
    
    private let decoder = JSONDecoder()
    
    func downloadComicsInfo(from url: URL) async throws -> XKCDComics {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ComicsError.serverError
        }
        
        do {
            let comics = try decoder.decode(XKCDComics.self, from: data)
            return comics
        } catch {
            throw ComicsError.parseJSONError
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


struct MockComicsFetcher: ComicsDownloader {
    func downloadComicsInfo(from url: URL) async throws -> XKCDComics {
        let comics = XKCDComics(
            number: 614,
            link: "https://xkcd.com/614/info.0.json",
            text: "If you don't have an extension cord I can get that too.  Because we're friends!  Right?",
            imageURL: URL(string: "https://imgs.xkcd.com/comics/woodpecker.png"),
            title: "Woodpecker")
        return comics
    }
}
