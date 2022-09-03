import XCTest
@testable import xkcdBrowser

final class ComicServiceTests: XCTestCase {

    var sut: ComicService!
    var fetcher: MockAPIFetcher!
    var diskStorage: MockDiskStorage!
    var previewData: PreviewData!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = ComicService.shared
        previewData = PreviewData()
        fetcher = MockAPIFetcher(preview: previewData)
        diskStorage = MockDiskStorage(preview: previewData)
        Task {
            try await sut.setUp(fetcher: fetcher, storage: diskStorage)
        }
    }

    override func tearDownWithError() throws {
        sut = nil
        fetcher = nil
        diskStorage = nil
        try super.tearDownWithError()
    }

    func test_comicService_canStore() async throws {
        let json = try XCTUnwrap(previewData.decodedJSON.randomElement())
        let key = URL(string: "https://comicstore.test")!
        let comic = Comic(comicData: json, url: key)
        
        await sut.store(comic: comic, forKey: key)
        
        XCTAssertTrue(diskStorage.saveCalled)
    }
    
    func test_comicService_return_singleComic_FromCache() async throws {
        let index = previewData.startIndex
        let cachedURL = ComicEndpoint.byIndex(index).url
        diskStorage.populateWithTestData()
        
        let cachedComic = try await sut.comic(cachedURL)
        
        XCTAssertEqual(cachedComic.id, index)
        XCTAssertTrue(diskStorage.loadCalled)
        XCTAssertFalse(fetcher.downloadCalled)
    }
    
    func test_comicService_return_singleComic_FromServer() async throws {
        let index = previewData.startIndex
        let cachedURL = ComicEndpoint.byIndex(index).url
        
        let cachedComic = try await sut.comic(cachedURL)
        
        XCTAssertEqual(cachedComic.id, index)
        XCTAssertFalse(diskStorage.loadCalled)
        XCTAssertTrue(fetcher.downloadCalled)
    }
    
    func test_comicService_return_multipleComics() async throws {
        var urls: [URL] = []
        let fetchCount = 5
        for idx in previewData.startIndex..<(previewData.startIndex + fetchCount) {
            let url = ComicEndpoint.byIndex(idx).url
            urls.append(url)
        }
        diskStorage.populateWithTestData()
        
        let cachedComics = try await sut.comics(urls)
        
        XCTAssertEqual(cachedComics.count, fetchCount)
        XCTAssertTrue(diskStorage.loadCalled)
        XCTAssertFalse(fetcher.downloadCalled)
    }
    
    func test_comicService_clearCache() async {
        diskStorage.populateWithTestData()
        let initialCacheCount = diskStorage.inMemoryStore.count
        
        await sut.clear()
        
        let afterClearingCacheCount = diskStorage.inMemoryStore.count
        
        XCTAssertGreaterThan(initialCacheCount, 0)
        XCTAssertEqual(afterClearingCacheCount, 0)
        XCTAssertTrue(diskStorage.removeCalled)
    }
}
