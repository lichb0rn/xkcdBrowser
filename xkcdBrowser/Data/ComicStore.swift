import Foundation
import UIKit


final class ComicStore: ObservableObject {
    
    @Published private(set) var comics: [Comic] = []
    @Published private(set) var showError: Bool = false
    
    private let fetcher: Fetching
    private var isFetching: Bool = false
    private let imageDownloader: ImageDownloader
    
    // The latest comic num, i.e 2657. Never less than 1.
    private var latestIndex: Int = -1
    
    private let prefetchCount: Int
    // How far in advance should the next comics be fetched, should be less than prefetchCount
    private let prefetchMargin: Int
    

    init(prefetchCount: Int = 10, prefetchMargin: Int = 5, fetcher: Fetching = Fetcher(), imageDownloader: ImageDownloader = ImageService.shared) {
        self.fetcher = fetcher
        self.imageDownloader = imageDownloader
        self.prefetchCount = prefetchCount
        self.prefetchMargin = prefetchMargin
    }
    
    func fetch() async {
        guard latestIndex < 1 else { return }

        await fetchLatest()
    }
    
    func fetch(currentIndex: Int) async {
        guard currentIndex < latestIndex + prefetchMargin else { return }

        await fetchMany(count: prefetchCount)
    }
    
    func downloadImage(for comic: Comic) async -> UIImage? {
        do {
            let uiImage = try await imageDownloader.downloadImage(fromURL: comic.imageURL)
            return uiImage
        } catch {
            return nil
        }
    }
    
    func markAsViewed(_ comic: Comic) {
        if let index = comics.firstIndex(of: comic) {
            comics[index].markViewed()
        }
    }
    
    @MainActor
    private func fetchLatest() async {
        isFetching = true
        defer {
            isFetching = false
        }
        do {
            let data = try await fetcher.downloadItem(fromURL: ComicEndpoint.current.url, ofType: ComicAPIEntity.self)
            let comic = Comic(comicData: data)
            latestIndex = comic.id
            comics.append(comic)
        } catch {
            print(error.localizedDescription)
            showError = true
        }
    }
    
    @MainActor
    private func fetchMany(count: Int) async {
        guard !isFetching else { return }
        isFetching = true
        defer {
            isFetching = false
        }
        
        let urls = getURLs(startIndex: latestIndex - 1, count: count)
        do {
            let data = try await fetcher.downloadItems(fromURLs: urls, ofType: ComicAPIEntity.self)
            let items = data
                .map({ Comic(comicData: $0) })
                .sorted(by: { $0.id > $1.id })
            
            comics.append(contentsOf: items)
            latestIndex = latestIndex - count
        } catch {
            print(error.localizedDescription)
        }
    }
    
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