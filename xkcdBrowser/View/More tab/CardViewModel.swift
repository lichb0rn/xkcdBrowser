import SwiftUI


class CardViewModel: ObservableObject {

    private let index: Int
    private let fetcher: ComicsDownloader
    private let imageService: ImageDownloader

    @Published var title: String = ""
    @Published var image: UIImage = UIImage()
    @Published var number: String = ""
    @Published var isLoading: Bool = false

    init(index: Int, imageService: ImageDownloader, fetcher: ComicsDownloader = ComicsFetcher()) {
        self.imageService = imageService
        self.fetcher = fetcher
        self.index = index
    }

    @MainActor
    func fetch() async {
        isLoading = true
        do {
            let comics = try await fetcher.downloadComicsInfo(from: ComicsEndpoint.version(number: self.index).url)
            image = try await imageService.downloadImage(fromURL: comics.imageURL!)
            title = comics.title
            number = "#" + String(comics.number)
        } catch {
            title = "Something went wrong... :("
            image = UIImage(named: "error")!
        }
        isLoading = false
    }
}


extension CardViewModel {
    convenience init(preview: Bool = true) {
        self.init(index: 614, imageService: MockImageService(), fetcher: MockComicsFetcher())
        title = "Woodpecker"
        image = UIImage(named: "error")!
    }
}
