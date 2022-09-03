import Foundation
import UIKit

final class AppFactory {
    
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
        return createStoreWithMocks()
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

    @MainActor private func createStoreWithMocks() -> ComicStore {
        let previewData = PreviewData()
        let mockComicService = MockComicService()
        for json in previewData.decodedJSON {
            let comic = Comic(comicData: json, url: ComicEndpoint.byIndex(json.id).url)
            Task {
                await mockComicService.store(comic: comic, forKey: comic.comicURL)
            }
        }
        
        return ComicStore(comicService: mockComicService)
    }
}
