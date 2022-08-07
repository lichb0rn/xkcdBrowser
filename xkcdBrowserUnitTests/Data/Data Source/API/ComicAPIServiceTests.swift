import XCTest
@testable import xkcdBrowser

final class ComicAPIServiceTests: XCTestCase {

    var sut: ComicDataSource!
    var previewData: PreviewData!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        previewData = PreviewData()
        sut = ComicAPIService()
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    
    func testDataSource_getSingleComic() async throws {
        let comicData = previewData.comic(withIndex: 633)
        let expectedComic = Comic(downloader: ImageService.shared, comicData: comicData)
        
        let receivedComic = try await sut.getComics(fromIndex: -1)
        
        XCTAssertEqual(expectedComic.comicID, receivedComic.first?.comicID)
    }
}
