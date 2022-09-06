import Foundation
import UIKit

final class AppFactory {
    
    @MainActor func initStore() -> ComicStore {
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
        return createStoreWithMocks(prefetchCount: prefetchCount, prefetchMargin: prefetchMargin)
//        return ComicStore(prefetchCount: prefetchCount, prefetchMargin: prefetchMargin, comicService: ComicService.shared)
#else
        return ComicStore(prefetchCount: prefetchCount, prefetchMargin: prefetchMargin, comicService: ComicService.shared)
#endif
    }
    
    @discardableResult
    func initProdStorageService() async throws->  ComicService {
        
        let diskStorage = await DiskStorage()
        let fetcher = Fetcher()
        do {
            try await ComicService.shared.setUp(fetcher: fetcher, storage: diskStorage)
            return ComicService.shared
        } catch {
            fatalError("Could not set up database")
        }
        
    }

    // ToDo: Refactor here
    // The app should start with the `real` ComicService but with mocked fetcher
    @MainActor private func createStoreWithMocks(prefetchCount: Int, prefetchMargin: Int) -> ComicStore {
        let previewData = PreviewData()
        let mockComicService = MockComicService()
        for json in previewData.decodedJSON {
            let comic = Comic(entity: json, url: ComicEndpoint.byIndex(json.id).url)
            Task {
                await mockComicService.store(comic: comic, forKey: comic.comicURL)
            }
        }
        
        return ComicStore(prefetchCount: prefetchCount,
                          prefetchMargin: prefetchMargin,
                          comicService: mockComicService)
    }
}
