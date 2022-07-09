import SwiftUI
import Combine

/// Grid ViewModel
final class ComicGridViewModel: ObservableObject {
    
    @Published var feed: [ComicItem] = []
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
            let latest = try await fetcher.fetchComicItem(withIndex: 0)
            maxIndex = latest.num
            lastIndexFetched = latest.num
            feed.append(latest)
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
        do {
            let comicItems = try await fetcher.fetchNextComicItems(from: nextIndex, count: prefetchCount)
            feed.append(contentsOf: comicItems)
            lastIndexFetched -= prefetchCount
        } catch {
            print(error.localizedDescription)
        }
        isFetching = false
    }
}
