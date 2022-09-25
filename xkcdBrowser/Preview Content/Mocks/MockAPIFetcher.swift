import Foundation
import UIKit

class MockAPIFetcher: Fetching {
    let previewData: PreviewData
    
    var isUnitTesting: Bool
    var downloadCalled: Bool = false
    var shouldThrow: Bool = false
    var exceptionToThrow: NetworkError = NetworkError.badServerResponse
    
    init(isUnitTesting: Bool = false, preview: PreviewData = PreviewData()) {
        self.isUnitTesting = isUnitTesting
        self.previewData = preview
    }
    
    func downloadItem(fromURL url: URL) async throws -> Data {
        downloadCalled = true
        if shouldThrow { throw exceptionToThrow }
        
        if isUnitTesting {
            return UIImage(named: "xkcd-people")!.pngData()!
        }
        
        guard let data = MockImageService.loadDataFromFile(url) else {
            throw exceptionToThrow
        }
        return data
    }
    
    
    func downloadItem<T: Decodable>(fromURL url: URL, ofType model: T.Type) async throws -> T {
        downloadCalled = true
        if shouldThrow { throw exceptionToThrow }
        
        guard let data = previewData.fetchData(url) else {
            throw exceptionToThrow
        }
        return try JSONDecoder().decode(model, from: data)
    }
    
    func downloadItems<T: Decodable>(fromURLs urls: [URL], ofType model: T.Type) async throws -> [T] {
        downloadCalled = true
        if shouldThrow { throw exceptionToThrow }
        
        let items = urls.compactMap { url in
            previewData.fetchData(url)
        }
        return items.shuffled() as! [T]
    }
}
