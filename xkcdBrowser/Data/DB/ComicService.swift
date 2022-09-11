import Foundation

enum ComicCacheError: Error {
    case fileDoesNotExist
    case directoryDoesNotExist
    case cacheMiss
}


/*
    We need Global Actor here to execute Storage code in the ComicDatabase context.
    I could make Storage an actor itself, but in this case we don't have 'actor hopping'.
 */

protocol ComicCacheService: Actor {
    func store(comic: Comic, forKey: URL) async
    func comic(_ url: URL) async throws -> Comic
    func comics(_ urls: [URL]) async throws -> [Comic]
    func clear() async
}

@globalActor
actor ComicService: ComicCacheService {
    static let shared = ComicService()
    
    private var storage: Storage!
    private var fetcher: Fetching!
    // Keeping track of stored comics on disk, so we don't need to refetch them
    private var storedIndexes = Set<String>()
    
    private init() { }
    
    // Having a shared instance is a requirement for @globalActor
    // But we still want dependency injection
    func setUp(fetcher: Fetching, storage: Storage) async throws {
        self.fetcher = fetcher
        self.storage = storage
        for file in try await storage.persistedEntities() {
            storedIndexes.insert(file.lastPathComponent)
        }
    }
    
    func store(comic: Comic, forKey key: URL) async {
        guard let data = try? JSONEncoder().encode(comic) else {
            return
        }
        
        let entityName = storage.entityName(key)

        do {
            try await storage.save(data, entityName)
            storedIndexes.insert(entityName)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func loadFromDisk(_ entityName: String) async throws -> Comic {
        let data = try await storage.load(entityName)
        let comic = try JSONDecoder().decode(Comic.self, from: data)
        return comic
    }
    
    func comic(_ url: URL) async throws -> Comic {
        do {
            let entityName = storage.entityName(url)
            // Checking if we have a cached version
            if !storedIndexes.contains(entityName) {
                // If we don't, throw a error and fetch from the server in the `catch` block
                throw ComicCacheError.cacheMiss
            }
            return try await loadFromDisk(entityName)
        } catch {
            let apiEntity = try await fetcher.downloadItem(fromURL: url, ofType: ComicAPIEntity.self)
            
            // Since the latest comic url differs from all other we need to reconstruct it from the comic id
            let comicURL = ComicEndpoint.byIndex(apiEntity.id).url
            
            // And re-check if it's been cached
            let entityName = storage.entityName(comicURL)
            if !storedIndexes.contains(entityName) {
                let comic = Comic(entity: apiEntity, url: comicURL)
                await store(comic: comic, forKey: comicURL)
                return comic
            } else {
                return try await loadFromDisk(entityName)
            }
        }
    }
    
    func comics(_ urls: [URL]) async throws -> [Comic] {
        guard !urls.isEmpty else { return [] }
        
        let results = try await withThrowingTaskGroup(of: Comic.self) { group in
            var items: [Comic] = []
            items.reserveCapacity(urls.count)
            
            urls.forEach { url in
                group.addTask(priority: .userInitiated) {
                    return try await self.comic(url)
                }
            }
            
            for try await comic in group {
                items.append(comic)
            }
            // ToDo: sorting should be made by DB
            return items.sorted(by: { $0.id > $1.id })
        }
        
        return results
    }

    func clear() async {
        for name in storedIndexes {
            try? await storage.remove(name)
        }
        storedIndexes.removeAll()
    }
    
}
