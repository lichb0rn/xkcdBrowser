import Foundation
import UIKit

@MainActor
final class ComicStore: ObservableObject {
    
    @Published private(set) var comics: [Comic] = []
    @Published private(set) var showError: Bool = false

    
    private var isFetching: Bool = false
    private let imageDownloader: ImageDownloader
    private let comicService: ComicCacheService
    
    // The latest comic num, i.e 2657. Never less than 1.
    private var latestIndex: Int = -1
    
    private let prefetchCount: Int
    // How far in advance should the next comics be fetched, should be less than prefetchCount
    private let prefetchMargin: Int
    
    init(prefetchCount: Int, prefetchMargin: Int, comicService: ComicCacheService, imageDownloader: ImageDownloader) {
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
    
    func markAsViewed(_ comic: Comic) {
        var mutated = comic
        mutated.markViewed()
        if let index = comics.firstIndex(of: comic) {
            comics[index] = mutated
            Task {
                await comicService.store(comic: mutated, forKey: mutated.comicURL)
            }
        }
    }
    
    private func updateUI(with contents: [Comic]) {
        comics.append(contentsOf: contents)
    }
}

// --------------------------------------
// MARK: - Networking and Storage
// --------------------------------------
extension ComicStore {
    func downloadImage(for comic: Comic, ofSize size: CGSize) async -> UIImage? {
        do {
            let uiImage = try await imageDownloader.downloadImage(fromURL: comic.imageURL, ofSize: size)
            return uiImage
        } catch {
            return nil
        }
    }
    
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
    
    private func fetchMoreIfNeeded(count: Int) async {
        guard !isFetching else { return }
        isFetching = true
        defer {
            isFetching = false
        }
        
        let urlsToFetch = getURLs(startIndex: latestIndex - 1, count: count)
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
    
        // Fetching from larger index to smaller
        for index in stride(from: startIndex, to: end, by: step) {
            urls.append(ComicEndpoint.byIndex(index).url)
        }
        return urls
    }
}
