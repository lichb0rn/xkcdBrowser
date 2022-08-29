import Foundation
import UIKit

final class AppContainer {
    
    @MainActor func initStore() -> ComicStore {
        let prefetchMargin: Int
        let prefetchCount: Int
        if UIDevice.current.userInterfaceIdiom == .pad {
            prefetchCount = 30
            prefetchMargin = 10
        } else {
            prefetchCount = 10
            prefetchMargin = 5
        }
        
#if DEBUG
        //        return ComicStore(prefetchCount: prefetchCount, prefetchMargin: prefetchMargin, fetcher: MockAPIFetcher())
        return ComicStore(prefetchCount: prefetchCount, prefetchMargin: prefetchMargin, comicService: ComicService.shared)
#else
        return ComicStore(prefetchCount: prefetchCount, prefetchMargin: prefetchMargin)
#endif
    }
    
    
    func initDatabase() async ->  ComicService {
        
        let diskStorage = await DiskStorage()
        let fetcher = Fetcher()
        do {
            try await ComicService.shared.setUp(fetcher: fetcher, storage: diskStorage)
            return ComicService.shared
        } catch {
            fatalError("Could not set up database")
        }
        
    }
}
