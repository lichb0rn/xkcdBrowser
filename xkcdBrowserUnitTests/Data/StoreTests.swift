import XCTest
import Combine
@testable import xkcdBrowser

final class StoreTests: XCTestCase {
    
    var sut: ComicStore!
    var networking: MockNetworking!
    var fetcher: Fetching!
    var previewData: PreviewData!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        previewData = PreviewData()
        networking = MockNetworking()
        fetcher = Fetcher(networking: networking)
        
        sut = ComicStore(fetcher: fetcher)
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        sut = nil
        fetcher = nil
        networking = nil
        previewData = nil
    }
    
    func test_onLoad_stateIsIdle() {
        XCTAssertEqual(sut.state, .idle)
    }
    
    func test_fetchLatestComic() async throws {
        let comicData = previewData.comicData()
        networking.result = .success(comicData)
        let expectedComic = Comic(comicData: try! JSONDecoder().decode(ComicAPIEntity.self, from: comicData))
        
        await sut.fetchLatest()
        
        let receivedComic = try XCTUnwrap(sut.comics.last)
        
        XCTAssertEqual(sut.state, .completed)
        XCTAssertEqual(receivedComic.id, expectedComic.id)
    }

    func test_fetchFailed_stateIsError() async {
        networking.result = .failure(NetworkError.requestError)
        
        await sut.fetchLatest()
        
        XCTAssertEqual(sut.state, .error)
    }
}
