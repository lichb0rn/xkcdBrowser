//import SwiftUI
//
//@MainActor
//class ComicViewModel: ObservableObject {
//
//    private let imageService: ImageDownloader
//    private let fetcher: ComicDownloader
//
//    @Published var isLoading: Bool = true
//    @Published var image: UIImage = UIImage()
//    @Published var title: String = ""
//    @Published var alt: String = ""
//
//    @Published var hasOldComics: Bool = true
//    @Published var hasNewComics: Bool = false
//
//    @Published var currentIndex: Int = 1 {
//        didSet {
//            hasOldComics = currentIndex > 1
//            hasNewComics = currentIndex < maxIndex
//            guard (1...maxIndex).contains(currentIndex) else { return }
//            Task {
//                await fetchSpecific(with: currentIndex)
//            }
//
//        }
//    }
//
//    @Published var hasError: Bool = false
//    private(set) var errorDescription: String = ""
//
//    // maxIndex is the latest comics number
//    private var maxIndex: Int = 1
//
//    private let decoder = JSONDecoder()
//    init(imageService: ImageDownloader, fetcher: ComicDownloader = ComicFetcher()) {
//        self.imageService = imageService
//        self.fetcher = fetcher
//    }
//
//
//    func fetchCurrent() async {
//        isLoading = true
//        do {
//            let comics = try await fetcher.downloadComicInfo(from: ComicEndpoint.current.url)
//            let img = try await imageService.downloadImage(fromURL: comics.imageUrl)
//            maxIndex = comics.id
//            updateUI(comics: comics, image: img)
//            currentIndex = comics.id
//        } catch (let error) {
//            errorDescription = error.localizedDescription
//            hasError = true
//        }
//    }
//
//    private func updateUI(comics: XKCDComic, image: UIImage) {
//        isLoading = false
//        self.image = image
//        self.title = comics.title
//        self.alt = comics.text
//    }
//
//    private func fetchSpecific(with index: Int) async {
//        isLoading = true
//        do {
//            let comics = try await fetcher.downloadComicInfo(from: ComicEndpoint.version(number: index).url)
//            let img = try await imageService.downloadImage(fromURL: comics.imageUrl)
//            updateUI(comics: comics, image: img)
//        } catch (let error) {
//            errorDescription = error.localizedDescription
//            hasError = true
//        }
//
//    }
//}
