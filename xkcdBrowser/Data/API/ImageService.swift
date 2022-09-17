import UIKit

protocol ImageDownloader: Actor {
    func downloadImage(fromURL url: URL, ofSize size: CGSize) async throws -> UIImage
    func add(_ image: UIImage, key: URL)
    func clearDiskCache() async
}


actor ImageService {    
    enum State {
        case inProgress(Task<UIImage, Error>)
        case completed(UIImage)
        case failed
    }
    
    private let fetcher: Fetching
    private var cache: [URL: State] = [:]
    
    init(fetcher: Fetching) {
        self.fetcher = fetcher
    }
    
    func downloadImage(fromURL url: URL, ofSize size: CGSize) async throws -> UIImage {
        if let cached = cache[url] {
            switch cached {
            case .completed(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            case .failed:
                throw NetworkError.requestError
            }
        }
        
        if let image = try? loadFromFile(fromURL: url) {
            add(image, key: url)
            return image
        }
        
        let downloadTask: Task<UIImage, Error> = Task.detached(priority: .userInitiated) {
            let data = try await self.fetcher.downloadItem(fromURL: url)
            
            if size == .zero {
                guard let image = UIImage(data: data) else {
                    throw NetworkError.decodingError
                }
                return image
            } else {
                guard let image = UIImage.downsample(imageData: data, to: size) else {
                    throw NetworkError.decodingError
                }
                return image
            }
        }
        
        cache[url] = .inProgress(downloadTask)
        
        do {
            let image = try await downloadTask.value
            add(image, key: url)
            saveImageToDisk(image, key: url)
            return image
        } catch {
            cache[url] = .failed
            throw NetworkError.requestError
        }
    }
    
    func add(_ image: UIImage, key: URL) {
        cache[key] = cache[key, default: .completed(image)]
    }
    
    func clearDiskCache() async {
        cache.keys.forEach {
            removeImageFile($0)
        }
        
        cache.removeAll()
    }
    
    private func getFileName(_ url: URL) -> URL? {
        let fileName = url.lastPathComponent
        guard let applicationSupport = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return applicationSupport.appendingPathComponent(fileName)
    }
    
    private func loadFromFile(fromURL url: URL) throws -> UIImage? {
        guard let fileName = getFileName(url) else { return nil }
        let data = try Data(contentsOf: fileName)
                
        return UIImage(data: data)
    }
    
    private func saveImageToDisk(_ image: UIImage, key: URL) {
        guard let fileName = getFileName(key),
              let data = image.pngData() else {
            return
        }
        
        try? data.write(to: fileName)
    }
    
    private func removeImageFile(_ url: URL) {
        guard let fileName = getFileName(url) else { return }
        try? FileManager.default.removeItem(at: fileName)
    }
}

extension ImageService: ImageDownloader {}


