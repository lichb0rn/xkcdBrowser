import SwiftUI

@MainActor
class ComicsViewModel: ObservableObject {

    private let imageService: ImageService
    private let fetcher: ComicsDownloader

    @Published var isLoading: Bool = true
    @Published var image: UIImage = UIImage()
    @Published var title: String = ""
    @Published var alt: String = ""

    @Published var hasOldComics: Bool = true
    @Published var hasNewComics: Bool = false

    @Published var currentIndex: Int = -1 {
        didSet {
            hasOldComics = currentIndex > 1
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
    init(imageService: ImageService, fetcher: ComicsDownloader = ComicsFetcher()) {
        self.imageService = imageService
        self.fetcher = fetcher
    }


    func fetchCurrent() async {
        isLoading = true
        do {
            let comics = try await fetcher.downloadComicsInfo(from: ComicsEndpoint.current.url)
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
        isLoading = true
        do {
            let comics = try await fetcher.downloadComicsInfo(from: ComicsEndpoint.version(number: index).url)
            let img = try await imageService.downloadImage(fromURL: comics.imageURL!)
            updateUI(comics: comics, image: img)
        } catch (let error) {
            errorDescription = error.localizedDescription
            hasError = true
        }

    }
}
