import Foundation
import UIKit

class MockAPIFetcher: Fetching {
    let previewData: PreviewData
    
    var downloadCalled: Bool = false
    var shouldThrow: Bool = false
    var exceptionToThrow: NetworkError = NetworkError.badServerResponse
    
    init(preview: PreviewData = PreviewData()) {
        self.previewData = preview
    }
    
    func downloadItem(fromURL url: URL) async throws -> Data {
        downloadCalled = true
        if shouldThrow { throw exceptionToThrow }
        
        let img = UIImage(named: "xkcd-people")!.pngData()!
        
        return img
    }
    
    func downloadItem<T: Decodable>(fromURL url: URL, ofType model: T.Type) async throws -> T {
        downloadCalled = true
        if shouldThrow { throw exceptionToThrow }
        
        if let comic = previewData.comic(withURL: url) {
            return comic as! T
        } else {
            return previewData.decodedJSON.first! as! T
        }
    }
    
    func downloadItems<T: Decodable>(fromURLs urls: [URL], ofType model: T.Type) async throws -> [T] {
        downloadCalled = true
        if shouldThrow { throw exceptionToThrow }
        
        let items = urls.compactMap {
            previewData.comic(withURL: $0)
        }
        return items.shuffled() as! [T]
    }
}
