import SwiftUI

class XKCDViewModel: ObservableObject {

    @Published var feed: [XKCDComics] = []
    let maxNumber: Int = .max

    func download(withNumber number: Int? = nil) async throws -> XKCDComics {
        var url: URL
        if let number = number {
            url = ComicsVersion.version(number: number).url
        } else {
            url = ComicsVersion.current.url
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw XKCDError.serverError
        }

        do {
            let comics = try JSONDecoder().decode(XKCDComics.self, from: data)
            await MainActor.run  {
                feed.append(comics)
            }
            return comics
        } catch {
            throw XKCDError.serverError
        }
    }
}

extension XKCDViewModel {
    enum ComicsVersion {
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
}

enum XKCDError: Error {
    case networkError
    case serverError
    case parseJSONError
}
