import Foundation
import UIKit

@MainActor
final class ComicStore: ObservableObject {
    
    @Published private(set) var comics: [Comic] = []
    @Published private(set) var showError: Bool = false
    
//    private let fetcher: Fetching
//    private var dbManager: Storage
    
    private var isFetching: Bool = false
    private let imageDownloader: ImageDownloader
    private let comicService: ComicDataSource
    
    // The latest comic num, i.e 2657. Never less than 1.
    private var latestIndex: Int = -1
    
    private let prefetchCount: Int
    // How far in advance should the next comics be fetched, should be less than prefetchCount
    private let prefetchMargin: Int
    

//    init(prefetchCount: Int = 10, prefetchMargin: Int = 5, fetcher: Fetching = Fetcher(), imageDownloader: ImageDownloader = ImageService(), dbManager: Storage = DiskStorage()) {
//        self.fetcher = fetcher
//        self.imageDownloader = imageDownloader
//        self.prefetchCount = prefetchCount
//        self.prefetchMargin = prefetchMargin
//        self.dbManager = dbManager
//    }
//
    init(prefetchCount: Int = 10, prefetchMargin: Int = 5, comicService: ComicDataSource, imageDownloader: ImageDownloader = ImageService()) {
//        self.fetcher = fetcher
//        self.dbManager = dbManager
        self.imageDownloader = imageDownloader
        self.prefetchCount = prefetchCount
        self.prefetchMargin = prefetchMargin
        self.comicService = comicService
    }
    
    
    func fetch() async {
        guard latestIndex < 1 else { return }

        await fetchLatest()
    }
    
    func fetch(currentIndex: Int) async {
        guard currentIndex < latestIndex + prefetchMargin else { return }

        await fetchMoreIfNeeded(count: prefetchCount)
    }
    
    func downloadImage(for comic: Comic, ofSize size: CGSize) async -> UIImage? {
        do {
            let uiImage = try await imageDownloader.downloadImage(fromURL: comic.imageURL, ofSize: size)
            return uiImage
        } catch {
            return nil
        }
    }
    
    func markAsViewed(_ comic: Comic) {
        if let index = comics.firstIndex(of: comic) {
//            await MainActor.run {
                comics[index].markViewed()
//            }

        }
    }
    
    private func updateUI(with contents: [Comic]) {
        comics.append(contentsOf: contents)
    }
}

// --------------------------------------
// MARK: - Networking
// --------------------------------------
extension ComicStore {
    
//    private func fetchLatest() async {
//        isFetching = true
//        defer {
//            isFetching = false
//        }
//
//        do {
//            let data = try await fetcher.downloadItem(fromURL: ComicEndpoint.current.url, ofType: ComicAPIEntity.self)
//            let comic = Comic(comicData: data)
//            latestIndex = comic.id
//            merge(newItems: [comic])
//            await updateUI(with: [comic])
//        } catch {
//            print(error.localizedDescription)
//            showError = true
//        }
//    }
    private func fetchLatest() async {
        isFetching = true
        defer {
            isFetching = false
        }
        
        do {
            let comic = try await comicService.comic(ComicEndpoint.current.url)
            latestIndex = comic.id
            updateUI(with: [comic])
        } catch {
            showError = true
        }
    }
    
    
//    private func fetchMoreIfNeeded(count: Int) async {
//        guard !isFetching else { return }
//        isFetching = true
//        defer {
//            isFetching = false
//        }
//
//        let urls = getURLs(startIndex: latestIndex - 1, count: count)
//        do {
//            let data = try await fetcher.downloadItems(fromURLs: urls, ofType: ComicAPIEntity.self)
//            let items = data
//                .map({ Comic(comicData: $0) })
//                .sorted(by: { $0.id > $1.id })
//
//            await updateUI(with: items)
//            latestIndex = latestIndex - count
//
//            DispatchQueue.global(qos: .background).async { [weak self] in
//                self?.saveToDisk(items)
//            }
//
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
    private func fetchMoreIfNeeded(count: Int) async {
        guard !isFetching else { return }
        isFetching = true
        defer {
            isFetching = false
        }
        
        let urlsToFetch = getURLs(startIndex: latestIndex - 1, count: 10)
        do {
            let items = try await comicService.comics(urlsToFetch)
            latestIndex = items.last?.id ?? 1
            updateUI(with: items)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    // Getting URLs by comic num
    private func getURLs(startIndex: Int, count: Int, reversed: Bool = true) -> [URL] {
        let end = startIndex - count
        let step = reversed ? -1 : 1
        var urls: [URL] = []
    
        for index in stride(from: startIndex, to: end, by: step) {
            urls.append(ComicEndpoint.byIndex(index).url)
        }
        return urls
    }
    

}
