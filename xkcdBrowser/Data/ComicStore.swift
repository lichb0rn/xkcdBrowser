import Foundation


final class ComicStore: ObservableObject {
    enum StoreState {
        case idle
        case fetching
        case completed
        case error
    }
    
    
    @Published private(set) var comics: [Comic] = []
    @Published private(set) var state: StoreState = .idle
    
    private let fetcher: Fetching
    private var isFetching: Bool = false
    
    // The latest comic num, i.e 2657. Never less than 1.
    private var latestIndex: Int = -1
    
    private let prefetchCount: Int
    // How far in advance should the next comics be fetched, should be less than prefetchCount
    private let prefetchMargin: Int
    

    init(fetcher: Fetching = Fetcher(), prefetchCount: Int = 10, prefetchMargin: Int = 5) {
        self.fetcher = fetcher
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
    
    @MainActor
    private func fetchLatest() async {
        state = .fetching
        do {
            let data = try await fetcher.downloadItem(fromURL: ComicEndpoint.current.url, ofType: ComicAPIEntity.self)
            let comic = Comic(comicData: data)
            latestIndex = comic.id
            comics.append(comic)
            state = .completed
        } catch {
            print(error.localizedDescription)
            state = .error
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
