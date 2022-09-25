import Foundation
import UIKit

final class AppFactory {
    
    @MainActor
    static func initStore() -> ComicStore {
        let prefetchMargin: Int
        let prefetchCount: Int
        if UIDevice.current.userInterfaceIdiom == .pad {
            prefetchCount = Settings.iPadPrefetchCount
            prefetchMargin = Settings.iPadPrefetchMargin
        } else {
            prefetchCount = Settings.iPhonePrefetchCount
            prefetchMargin = Settings.iPhonePrefetchMargin
        }
        
#if DEBUG
//        let fetcher = MockAPIFetcher()
        let fetcher = Fetcher()
#else
        let fetcher = Fetcher()
#endif
        AppFactory.setUpComicService(withFetcher: fetcher)
        let store = ComicStore(prefetchCount: prefetchCount,
                               prefetchMargin: prefetchMargin,
                               comicService: ComicService.shared,
                               imageDownloader: ImageService(fetcher: fetcher))
        
        return store
    }
    
    private static func setUpComicService(withFetcher fetcher: Fetching)   {
        Task {
            do {
                let diskStorage = await DiskStorage()
                try await ComicService.shared.setUp(fetcher: fetcher, storage: diskStorage)
            } catch {
                fatalError("Could not set up database")
            }
        }
    }
}
