import Foundation

enum DataSourceError: Error {
    case fileDoesNotExist
    case directoryDoesNotExist
    case cacheMiss
}


/*
    I need Global Actor here to execute Storage code in the ComicDatabase context.
    I could make Storage an actor itself, but in this case I don't have 'actor hopping'.
 */

protocol ComicDataSource: Actor {
    func store(comic: Comic, forKey: URL) async
    func comic(_ url: URL) async throws -> Comic
    func comics(_ urls: [URL]) async throws -> [Comic]
    func clear() async
}

@globalActor
actor ComicService: ComicDataSource {
    static let shared = ComicService()
    
    private var storage: Storage!
    private var fetcher: Fetching!
    // Keeping track of store comic ids on disk, so we don't need to refetch them
    private var storedIndexes = Set<String>()
    
    private init() { }
    
    func setUp(fetcher: Fetching, storage: Storage) async throws {
        self.fetcher = fetcher
        self.storage = storage
        for file in try await storage.persistedFiles() {
            storedIndexes.insert(file.lastPathComponent)
        }
    }
    
    func store(comic: Comic, forKey key: URL) async {
        guard let data = try? JSONEncoder().encode(comic) else {
            return
        }
        
        let fileName = DiskStorage.fileName(key)

        do {
            try await storage.save(data, fileName)
            storedIndexes.insert(fileName)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func comic(_ url: URL) async throws -> Comic {
        do {
            let fileName = DiskStorage.fileName(url)
            // Checking if we have a cached version
            if !storedIndexes.contains(fileName) {
                // If we don't, throw a error and fetch from the server in the `catch` block
                throw DataSourceError.cacheMiss
            }
            let data = try await storage.load(fileName)
            let comic = try JSONDecoder().decode(Comic.self, from: data)
            
            return comic
        } catch {
            let jsonData = try await fetcher.downloadItem(fromURL: url, ofType: ComicAPIEntity.self)
            
            // Since the latest comic url differes from all other we need to reconstructed it from the comic id
            let comicURL = ComicEndpoint.byIndex(jsonData.id).url
            let comic = Comic(comicData: jsonData, url: comicURL)
            
            await store(comic: comic, forKey: comicURL)
            return comic
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

extension Set {
    // Get uniq elements for set A and for sequence B
    func uniqSubsets<S>(_ s: S) -> (Set<Element>, Set<Element>) where S : Sequence, S.Element == Element {
        let uniqForSelf = self.intersection(s)
        let uniqForOther = Set(s).subtracting(self)
        
        return (uniqForSelf, uniqForOther)
    }
}