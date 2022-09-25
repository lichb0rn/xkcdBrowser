import UIKit

actor MockImageService: ImageDownloader {
    enum State {
        case inProgress(Task<UIImage, Error>)
        case completed(UIImage)
        case failed
    }
    
    private var cache: [String: State] = [:]
    
    func downloadImage(fromURL url: URL, ofSize size: CGSize) async throws -> UIImage {
        if let image = MockImageService.loadFromFile(url) {
            return image
        } else {
            throw NetworkError.badServerResponse
        }
    }

    func add(_ image: UIImage, key: URL) { }
    func clearDiskCache() async { }
}

extension MockImageService {
    nonisolated static func loadFromFile(_ url: URL) -> UIImage? {
        let fileName = urlToFilename(url)
        
        if let path = Bundle.main.path(forResource: fileName, ofType: "png") {
            return UIImage(contentsOfFile: path)
        }
        return nil
    }
    
    nonisolated static func loadDataFromFile(_ url: URL) -> Data? {
        let fileName = urlToFilename(url)
        
        if let path = Bundle.main.url(forResource: fileName, withExtension: "png") {
            return try? Data(contentsOf: path)
        }
        return nil
    }
    
    nonisolated static func urlToFilename(_ url: URL) -> String {
        return (url.lastPathComponent as NSString).deletingPathExtension
    }
}
