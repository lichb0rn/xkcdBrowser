import XCTest
import Combine
@testable import xkcdBrowser

final class StoreTests: XCTestCase {
    
    var sut: ComicStore!
    var fetcher: MockAPIFetcher!
    var previewData: PreviewData!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        previewData = PreviewData()
        fetcher = MockAPIFetcher(preview: previewData)
        sut = ComicStore(fetcher: fetcher)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        sut = nil
        fetcher = nil
        previewData = nil
    }
    
    func coldStart() async -> Comic {
        await sut.fetch()
        return sut.comics.last!
    }
    
    func test_onLoad_storeIsEmpty() {
        XCTAssertTrue(sut.comics.isEmpty)
    }
    
    func test_fetchLatestComic() async throws {
        let expectedComic = previewData.decodedJSON.last!
        
        await sut.fetch()
        
        let receivedComic = try XCTUnwrap(sut.comics.last!)
        
        XCTAssertEqual(receivedComic.id, expectedComic.id)
    }
    
    func test_prefetchMultipleComics() async throws {
        let fetched = await coldStart()
        
        await sut.fetch(currentIndex: fetched.id)
        
        XCTAssertEqual(sut.comics.count, 11) // Latest comic + 10 from prefetchCount = 11
    }

    func test_notFetching_ifNoNeed() async throws {
        let fetched = await coldStart()
        
        // Default prefetch margin is 5, index should be greater not to trigger prefetch
        await sut.fetch(currentIndex: fetched.id + 7)
        
        XCTAssertEqual(sut.comics.count, 1)
    }
    
    func test_store_HasNoDuplicates() async {
        var latest = await coldStart()
        await sut.fetch(currentIndex: latest.id)
        latest = sut.comics.last!
        await sut.fetch(currentIndex: latest.id)
        
        let hasNoDuplicates = sut.comics.count == Set(sut.comics).count
        
        XCTAssertTrue(hasNoDuplicates, "Comics publisher has duplicate items")
    }

    func test_fetchFailed_showErrorIsTrue() async {
        fetcher.shouldThrow = true
        
        await sut.fetch()
        
        XCTAssertTrue(sut.showError)
    }
}
