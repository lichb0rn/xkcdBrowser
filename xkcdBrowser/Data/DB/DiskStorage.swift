import Foundation


protocol DBManaging {
    func load() -> [Comic]
    func save(_ item: Comic)
}

class DiskStorage: DBManaging {
    
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
    }
    
    func save(_ item: Comic) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        print("FOLDER: \(folder)")
        
        do {
            let data = try encoder.encode(item)
            try data.write(to: folder.appendingPathComponent(item.title + ".json"), options: .atomic)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func load() -> [Comic] {
        guard let dirEnumerator = FileManager.default.enumerator(at: folder, includingPropertiesForKeys: []) else {
            return []
        }
        
        var items: [Comic?] = []
        for case let fileURL as URL in dirEnumerator {
            if let data = try? Data(contentsOf: fileURL) {
                items.append(try? JSONDecoder().decode(Comic.self, from: data))
            }
        }
        
        return items.compactMap { $0 }
    }
}





