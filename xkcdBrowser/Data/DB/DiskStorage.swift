import Foundation


protocol Storage {
    func load(_ name: String) async throws -> Data
    func save(_ entity: Data, _ name: String) async throws
    func remove(_ name: String) async throws

    func persistedEntities() async throws -> [URL]
}


@ComicService
class DiskStorage: Storage {    
    private var folder: URL
    
    init() {
        guard let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Could not open application support directory")
        }
        let databaseFolder = supportDirectory.appendingPathComponent("database")
        do {
            try FileManager.default.createDirectory(at: databaseFolder, withIntermediateDirectories: true)
        } catch {
            fatalError("Could not create database directory")
        }
        folder = databaseFolder
        print(folder)
    }
    
    func load(_ name: String) throws -> Data {
        return try Data(contentsOf: folder.appendingPathComponent(name))
    }
    
    func save(_ data: Data, _ fileName: String) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        try data.write(to: folder.appendingPathComponent(fileName))
    }
    
    func remove(_ name: String) throws {
        try FileManager.default.removeItem(at: folder.appendingPathComponent(name))
    }
    
    func persistedEntities() throws -> [URL] {
        guard let dirEnumerator = FileManager.default.enumerator(at: folder, includingPropertiesForKeys: []) else {
            throw DataSourceError.directoryDoesNotExist
        }
        
        var result = [URL]()
        for case let fileURL as URL in dirEnumerator {
            result.append(fileURL)
        }
        return result
    }
    
    // Not doing any mutation here, so it can be nonisolated
    nonisolated static func fileName(_ url: URL) -> String {
        return url.deletingLastPathComponent().lastPathComponent.appending(".json")
    }
}





