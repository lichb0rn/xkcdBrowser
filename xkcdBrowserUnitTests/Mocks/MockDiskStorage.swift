import Foundation
@testable import xkcdBrowser

class MockDiskStorage: Storage {
    
    let previewData: PreviewData
    var inMemoryStore: [String : Data] = [:]
    var shouldReturnEmptyCache: Bool = true
    
    var loadCalled: Bool = false
    var saveCalled: Bool = false
    var removeCalled: Bool = false
    var shouldFail: Bool = false
    
    init(preview: PreviewData = PreviewData()) {
        self.previewData = preview
    }
    
    func load(_ name: String) async throws -> Data {
        guard !shouldFail else { throw ComicCacheError.fileDoesNotExist }
        
        guard let d = inMemoryStore[name] else {
            throw NSError(domain: "storage", code: 9999)
        }
        loadCalled = true
        return d
    }
    
    func save(_ entity: Data, _ name: String) async throws {
        guard !shouldFail else { throw NSError(domain: "storage", code: 9997) }
        
        inMemoryStore[name] = entity
        saveCalled = true
    }
    
    func remove(_ name: String) async throws {
        guard !shouldFail else { throw NSError(domain: "storage", code: 9998) }
        
        inMemoryStore[name] = nil
        removeCalled = true
    }
    
    func persistedEntities() async throws -> [URL] {
        guard !shouldFail else { throw NSError(domain: "storage", code: 10000) }
        
        return inMemoryStore.keys.map { URL(string: $0)! }
    }
    
    func entityName(_ url: URL) -> String {
        return url.deletingLastPathComponent().lastPathComponent.appending(".json")
    }
    
    func populateWithTestData() {
        for idx in previewData.startIndex...previewData.endIndex {
            if let path = Bundle(for: MockDiskStorage.self).url(forResource: "\(idx)", withExtension: ".json") {
                do {
                    let d = try Data(contentsOf: path)
                    inMemoryStore[path.lastPathComponent] = d
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
