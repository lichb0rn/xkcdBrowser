import SwiftUI

class ComicsListViewModel: ObservableObject {

    private let fetcher: ComicsDownloader
    private let imageService: ImageDownloader

    @Published var comicsFeed: [XKCDComics] = []
    @Published var hasError: Bool = false
    var errorDescription: String = ""

    @Published private(set) var maxNumber: Int = 0

    init(imageService: ImageDownloader, fetcher: ComicsDownloader = ComicsFetcher()) {
        self.imageService = imageService
        self.fetcher = fetcher
        Task {
            await fetchLatest()
        }
    }

    func fetchLatest() async {
        do {
            let latestComics = try await fetcher.downloadComicsInfo(from: ComicsEndpoint.current.url)
            maxNumber = latestComics.number

        } catch {
            hasError = true
            errorDescription = error.localizedDescription
        }
    }

    func cardViewModel(for index: Int) -> CardViewModel {
        return CardViewModel(index: index, imageService: self.imageService)
    }
}


extension ComicsListViewModel {

}
