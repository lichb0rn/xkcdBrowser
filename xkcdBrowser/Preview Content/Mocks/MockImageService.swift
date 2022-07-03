import UIKit

actor MockImageService: ImageDownloader {
    enum State {
        case inProgress(Task<UIImage, Error>)
        case completed(UIImage)
        case failed
    }
    
    private var cache: [String: State] = [:]
    
    func downloadImage(fromURL url: URL) async throws -> UIImage {
        if let image = loadFromFile(url) {
            return image
        } else {
            throw NetworkError.serverError
        }
    }


    
    func add(_ image: UIImage, key: String) { }
}

extension MockImageService {
    nonisolated func loadFromFile(_ url: URL) -> UIImage? {
        let fileName = urlToFilename(url)
        
        if let path = Bundle.main.path(forResource: fileName, ofType: "png") {
            return UIImage(contentsOfFile: path)
        }
        return nil
    }
    
    nonisolated private func urlToFilename(_ url: URL) -> String {
        return (url.lastPathComponent as NSString).deletingPathExtension
    }
}
