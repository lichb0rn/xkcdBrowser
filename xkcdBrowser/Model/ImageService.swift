import UIKit

actor ImageService: ObservableObject {
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
                throw XKCDError.networkError
            }
        }

        let downloadTask: Task<UIImage, Error> = Task.detached {
            let data = try await URLSession.shared.data(from: url).0
            guard let image = UIImage(data: data) else {
                throw XKCDError.parseJSONError
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
            throw XKCDError.networkError
        }
    }

    func add(_ image: UIImage, key: String) {
        cache[key] = .completed(image)
    }
}

