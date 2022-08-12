import UIKit

protocol ImageDownloader: Actor {
    func downloadImage(fromURL url: URL) async throws -> UIImage
    func add(_ image: UIImage, key: String)
}

actor ImageService: ObservableObject {
    static let shared = ImageService()
    private init() {}

    enum State {
        case inProgress(Task<UIImage, Error>)
        case completed(UIImage)
        case failed
    }

    private var cache: [String: State] = [:]

    func downloadImage(fromURL url: URL) async throws -> UIImage {
        let key = url.absoluteString
        if let cached = cache[key] {
            switch cached {
            case .completed(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            case .failed:
                throw NetworkError.requestError
            }
        }

        let downloadTask: Task<UIImage, Error> = Task.detached {
            let data = try await URLSession.shared.data(from: url).0
            guard let image = UIImage(data: data) else {
                throw NetworkError.decodingError
            }
            return image
        }

        cache[key] = .inProgress(downloadTask)

        do {
            let image = try await downloadTask.value
            add(image, key: key)
            return image
        } catch {
            cache[key] = .failed
            throw NetworkError.requestError
        }
    }

    func add(_ image: UIImage, key: String) {
        cache[key] = cache[key, default: .completed(image)]
    }
}

extension ImageService: ImageDownloader {}

