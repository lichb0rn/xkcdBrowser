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
    private var latestIndex: Int = -1
    
    init(fetcher: Fetching = Fetcher()) {
        self.fetcher = fetcher
    }
    
    func fetch() async {
        await fetchLatest()
    }
    
    @MainActor
    func fetchLatest() async {
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
}
