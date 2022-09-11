import XCTest
@testable import xkcdBrowser

final class ImageServiceTests: XCTestCase {
    
    var sut: ImageService!
    var fetcher: MockAPIFetcher!
    var previewData: PreviewData!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        previewData = PreviewData()
        fetcher = MockAPIFetcher(preview: previewData)
        sut = ImageService(fetcher: fetcher)
    }

    override func tearDownWithError() throws {
        sut = nil
        fetcher = nil
        previewData = nil
        try super.tearDownWithError()
    }

    
}
