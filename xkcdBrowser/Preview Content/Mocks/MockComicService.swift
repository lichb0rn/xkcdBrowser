import Foundation


actor MockComicService: ComicCacheService {
    
    var data: [Comic] = []
    let preview = PreviewData()
    var error: Bool = false

    
    func store(comic: Comic, forKey key: URL) async {
        data.append(comic)
    }
    
    func comic(_ url: URL) async throws -> Comic {
        guard !error else {
            throw NetworkError.badServerResponse
        }

        if let comic = data.first(where: { $0.comicURL == url }) {
            return comic
        } else {
            return data.last!
        }
    }
    
    func comics(_ urls: [URL]) async throws -> [Comic] {
        guard !error else {
            throw NetworkError.badServerResponse
        }
        return data.filter { urls.contains($0.comicURL) }.sorted(by: { $0.id > $1.id })
    }
    
    func clear() async {
//        data.removeAll()
    }
    
    func shouldThrow() {
        error = true
    }

    
    private func makeTestData(comic: Comic, url: URL) {
        guard let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Could not open application support directory")
        }
        let databaseFolder = supportDirectory.appendingPathComponent("database")
        print(databaseFolder)
        let fileName = url.deletingLastPathComponent().lastPathComponent.appending(".json")
        do {
            let encoded = try JSONEncoder().encode(comic)
            try encoded.write(to: databaseFolder.appendingPathComponent(fileName))
            print("Saved to \(fileName): \(encoded)")
        } catch {
            print(error.localizedDescription)
        }
    }
}
