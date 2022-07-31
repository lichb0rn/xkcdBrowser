import SwiftUI
import RealmSwift

/// Grid ViewModel
final class ComicGridViewModel: ObservableObject {
    
//    @ObservedResults(ComicModel.self) var comics
    
    @Published private(set) var feed: [ComicGridItemViewModel] = []
    @Published var hasError: Bool = false
    
    private var fetcher: ComicDownloader
    
    private var isFetching: Bool = false
    private var maxIndex: Int = -1
    private var lastIndexFetched: Int = -1
    
    init(fetcher: ComicDownloader) {
        self.fetcher = fetcher
        
    }
    
    @MainActor
    func fetchLatests() async {
        isFetching = true
        do {
            let data = try await NetworkManager.downloadItem(fromURL: ComicEndpoint.current.url, ofType: XKCDComic.self)
            let latest = ComicItem(downloader: ImageService.shared, comicData: data)
            maxIndex = latest.num
            lastIndexFetched = latest.num
            let viewModel = ComicGridItemViewModel(comic: latest, id: 0)
            feed.append(viewModel)
            Task {
                await viewModel.fetchImage()
            }
        } catch {
            hasError = true
        }
        isFetching = false
    }
    
    @MainActor
    func fetchNextComics(prefetchCount: Int = 10) async {
        guard !isFetching else { return }
        guard (prefetchCount...maxIndex).contains(lastIndexFetched) else { return }
        
        isFetching = true
        let nextIndex = lastIndexFetched - 1
        let nextLastIndex = nextIndex - prefetchCount
        
        var urls: [URL] = []
        for index in stride(from: nextIndex, to: nextLastIndex, by: -1) {
            urls.append(ComicEndpoint.version(number: index).url)
        }
        
        do {
            let items = try await NetworkManager.downloadItems(fromURLs: urls, ofType: XKCDComic.self)
            let comicItems = items.map { ComicItem(downloader: ImageService.shared, comicData: $0) }
            
            let viewModels = comicItems.enumerated().map { (idx, item) in
                ComicGridItemViewModel(comic: item, id: feed.count + idx)
            }
        
            viewModels.forEach { viewModel in
                feed.append(viewModel)
                Task {
                    await viewModel.fetchImage()
                }
            }
            lastIndexFetched = nextLastIndex
        } catch {
            print(error.localizedDescription)
        }
        
        isFetching = false
    }
    
    func reset() {
        feed.removeAll()
        
    }
}
