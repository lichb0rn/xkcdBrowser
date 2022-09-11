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

    func expectedImage() -> UIImage {
        let img = UIImage(named: "xkcd-people")!
        return img
    }
    
    func test_returnImage_fromServer() async throws {
        let url = URL(string: "https://www.example.com")!
        let image = expectedImage()
        
        let img = try await sut.downloadImage(fromURL: url, ofSize: .zero)
        
        XCTAssertEqual(image.pngData()!, img.pngData()!)
        XCTAssertTrue(fetcher.downloadCalled)
    }
    
    func test_returnImage_fromMemory() async throws {
        let url = URL(string: "https://www.example.com")!
        let image = expectedImage()
        
        await sut.add(image, key: url)
        
        let returned = try await sut.downloadImage(fromURL: url, ofSize: .zero)
        
        XCTAssertEqual(image.pngData()!, returned.pngData()!)
        XCTAssertFalse(fetcher.downloadCalled)
    }
}
