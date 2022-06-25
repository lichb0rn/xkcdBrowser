import SwiftUI


/// Grid ViewModel
final class ComicGridViewModel: ObservableObject {
    
    @Published var feed: [ComicGridItemViewModel] = []
    
    @Published var hasError: Bool = false
    
    private var fetcher: ComicDownloader
    private var isFetching: Bool = false
    private var maxIndex: Int = -1
    
    init(fetcher: ComicDownloader) {
        self.fetcher = fetcher
    }
    
    @MainActor
    func fetchLatests() async {
        isFetching = true
        do {
            let latest = try await fetcher.fetchComicItem(withIndex: 0)
            maxIndex = latest.num
            let comicListViewModel = ComicGridItemViewModel(comic: latest)
            feed.append(comicListViewModel)
            Task {
                await comicListViewModel.fetchImage()
            }
        } catch {
            hasError = true
        }
        isFetching = false
    }
    
    @MainActor
    func fetch(currentIndex: Int) async {
        guard (1...maxIndex).contains(currentIndex) else { return }
        isFetching = true
        do {
            let nextIndex = currentIndex - 1
            let comicItem = try await fetcher.fetchComicItem(withIndex: nextIndex)
            let comicListViewModel = ComicGridItemViewModel(comic: comicItem)
            feed.append(comicListViewModel)
            Task {
                await comicListViewModel.fetchImage()
            }
        } catch {}
        isFetching = false
    }
}
