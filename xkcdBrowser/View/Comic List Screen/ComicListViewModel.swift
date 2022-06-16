import SwiftUI

@MainActor
class ComicListViewModel: ObservableObject {
    
    private let fetcher: ComicDownloader
    private let imageService: ImageDownloader
    
    @Published private(set) var feed: [ComicListItemViewModel] = []
    @Published private(set) var hasError: Bool = false
    
    private(set) var maxNumber: Int = 0
    
    init(imageService: ImageDownloader, fetcher: ComicDownloader = ComicFetcher()) {
        self.imageService = imageService
        self.fetcher = fetcher
    }
    
    func fetchLatest() async {
        do {
            let latestComic = try await fetcher.downloadComicInfo(from: ComicsEndpoint.current.url)
            maxNumber = latestComic.id
            updateFeed(latestComic)
            
        } catch {
            hasError = true
        }
    }
    
    func fetchMore(currentIndex: Int) async {
        guard currentIndex > 0 else { return }
        
        let nextComicIndex = currentIndex - 1
        do {
            try Task.checkCancellation()
            let comic = try await fetcher.downloadComicInfo(from: ComicsEndpoint.version(number: nextComicIndex).url)
            updateFeed(comic)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func updateFeed(_ comic: XKCDComic) {
        let viewModel = ComicListItemViewModel(comic: comic, imageService: imageService)
        feed.append(viewModel)
    }
}
