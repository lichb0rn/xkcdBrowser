import Foundation

struct MockAPIFetcher: Fetching {
    let previewData = PreviewData()
    
    func downloadItem<T: Decodable>(fromURL url: URL, ofType model: T.Type) async throws -> T {
        previewData.comic(withURL: url) as! T
    }
    
    func downloadItems<T: Decodable>(fromURLs urls: [URL], ofType model: T.Type) async throws -> [T] {
        let items: [T] = previewData.decodedJSON as! [T]
        return items.reversed()
    }
}
