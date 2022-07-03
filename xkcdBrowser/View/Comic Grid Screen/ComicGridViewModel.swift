import SwiftUI
import Combine

/// Grid ViewModel
final class ComicGridViewModel: ObservableObject {
    
    @Published var feed: [ComicGridItemViewModel] = []
    
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
    func fetch(currentIndex: Int, prefetchCount: Int = 5) async {
        guard (prefetchCount...maxIndex).contains(currentIndex) else { return }
        isFetching = true
//        do {
//            let nextIndex = currentIndex - 1
//            let comicItem = try await fetcher.fetchComicItem(withIndex: nextIndex)
//            let comicListViewModel = ComicGridItemViewModel(comic: comicItem)
//            feed.append(comicListViewModel)
//            Task {
//                await comicListViewModel.fetchImage()
//            }
//        } catch {}
        let nextIndex = lastIndexFetched - 1
        do {
            let comicItems = try await fetcher.fetchNextComicItems(from: nextIndex, count: prefetchCount)
            let viewModels = comicItems.map { ComicGridItemViewModel(comic: $0) }
            for viewModel in viewModels {
                feed.append(viewModel)
//                Task {
//                    await viewModel.fetchImage()
//                }
            }
            lastIndexFetched -= prefetchCount
        } catch {
            print(error.localizedDescription)
        }
        isFetching = false
    }
}
