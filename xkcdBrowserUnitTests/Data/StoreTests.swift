import XCTest
import Combine
@testable import xkcdBrowser

final class StoreTests: XCTestCase {
    
    var sut: ComicStore!
    var mockStorageService: MockComicService!
    var previewData: PreviewData!
    
    @MainActor
    override func setUp() async throws {
        try await super.setUp()
        previewData = PreviewData()
        mockStorageService = MockComicService()
        
        for json in previewData.decodedJSON {
            let comic = Comic(entity: json, url: ComicEndpoint.byIndex(json.id).url)
            await mockStorageService.store(comic: comic, forKey: comic.comicURL)
        }
        
        sut = ComicStore(prefetchCount: 10, prefetchMargin: 5, comicService: mockStorageService)
    }

    override func tearDown() async throws {
        try super.tearDownWithError()
        sut = nil
        mockStorageService = nil
        previewData = nil
    }
    
    func coldStart() async -> Comic {
        await sut.fetch()
        return await sut.comics.last!
    }
    
    func test_onLoad_storeIsEmpty() async {
        let empty: Bool = await sut.comics.isEmpty
        
        XCTAssertTrue(empty)
    }
    
    func test_fetchLatestComic() async throws {
        let expectedComic = previewData.decodedJSON.last!
        
        await sut.fetch()
        
        let receivedComic = await sut.comics.last
        
        XCTAssertEqual(try XCTUnwrap(receivedComic).id, expectedComic.id)
    }
    
    func test_prefetchMultipleComics() async throws {
        let fetched = await coldStart()
        
        await sut.fetch(currentIndex: fetched.id)
        
        let count = await sut.comics.count
        
        XCTAssertEqual(count, 11) // Latest comic + 10 from prefetchCount = 11
    }

    func test_notFetching_ifNoNeed() async throws {
        let fetched = await coldStart()
        
        // Default prefetch margin is 5, index should be greater not to trigger prefetch
        await sut.fetch(currentIndex: fetched.id + 7)
        
        let count = await sut.comics.count
        
        XCTAssertEqual(count, 1)
    }

    func test_store_HasNoDuplicates() async {
        var latest = await coldStart()
        await sut.fetch(currentIndex: latest.id)
        latest = await sut.comics.last!
        await sut.fetch(currentIndex: latest.id)
        
        let hasNoDuplicates = await sut.comics.count == Set(sut.comics).count
        
        XCTAssertTrue(hasNoDuplicates, "Comics publisher has duplicate items")
    }

    func test_fetchFailed_showErrorIsTrue() async {
        await mockStorageService.shouldThrow()
        
        await sut.fetch()
        let isError = await sut.showError
        
        XCTAssertTrue(isError)
    }
    
    func test_viewed_comic_marked() async throws {
        let comic = await coldStart()
        let id = comic.id
        
        await sut.markAsViewed(comic)
        
        let viewed = await sut.comics.first(where: { $0.isViewed == true })
        let viewedId = try XCTUnwrap(viewed).id
        XCTAssertEqual(id, viewedId)
    }
}
