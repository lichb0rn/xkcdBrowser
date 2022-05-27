import SwiftUI

@MainActor
class ComicsViewModel: ObservableObject {

    private let imageService: ImageService

    @Published var isLoading: Bool = true
    @Published var image: UIImage = UIImage()
    @Published var title: String = ""
    @Published var alt: String = ""

    @Published var hasOldComics: Bool = true
    @Published var hasNewComics: Bool = false

    @Published var currentIndex: Int = -1 {
        didSet {
            hasOldComics = currentIndex > 0
            hasNewComics = currentIndex < maxIndex - 1
            guard currentIndex != maxIndex else { return }
            Task {
                await fetchSpecific(with: currentIndex)
            }

        }
    }

    @Published var hasError: Bool = false
    private(set) var errorDescription: String = ""

    // maxIndex is the latest comics number
    private(set) var maxIndex: Int = .max

    private let decoder = JSONDecoder()
    init(imageService: ImageService) {
        self.imageService = imageService
    }


    func fetchCurrent() async {
        do {
            let comics = try await downloadComicsInfo(from: ComicsVersion.current.url)
            let img = try await imageService.downloadImage(fromURL: comics.imageURL!)
            maxIndex = comics.number
            updateUI(comics: comics, image: img)
            currentIndex = comics.number
        } catch (let error) {
            errorDescription = error.localizedDescription
            hasError = true
        }
    }

    private func updateUI(comics: XKCDComics, image: UIImage) {
        isLoading = false
        self.image = image
        self.title = comics.title
        self.alt = comics.text
    }

    private func fetchSpecific(with index: Int) async {
        do {
            let comics = try await downloadComicsInfo(from: ComicsVersion.version(number: index).url)
            let img = try await imageService.downloadImage(fromURL: comics.imageURL!)
            updateUI(comics: comics, image: img)
        } catch (let error) {
            errorDescription = error.localizedDescription
            hasError = true
        }

    }

    private func downloadComicsInfo(from url: URL) async throws -> XKCDComics {
        isLoading = true
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


extension ComicsViewModel {
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
