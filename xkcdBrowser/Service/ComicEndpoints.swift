import Foundation

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
