import Foundation


/// Struct to contain pre-downloaded comics for preview and testing
struct PreviewData {
    // First file stars from 614 (614.json) and the last one is 633
    let startIndex = 614
    let endIndex = 633
    
    // Keeping borth `raw` data and decoded JSON for different puproses (preview and testing)
    var decodedJSON: [ComicAPIEntity] = []
    var data: [Data] = []
    
    init() {
        self.loadRawData()
        self.decode()
    }
    
    mutating func loadRawData() {
        for idx in startIndex...endIndex {
            if let comicData = JSONPreviewLoader.load(fileName: "\(idx)")  {
                data.append(comicData)
            }
        }
    }
    
    mutating func decode() {
        decodedJSON = data.compactMap {
            do {
                return try JSONDecoder().decode(ComicAPIEntity.self, from: $0)
            } catch {
                return nil
            }
        }
    }
    
    func comicData() -> Data {
        return data.last!
    }
    
    func comic(withIndex index: Int) -> ComicAPIEntity {
        if let comic = decodedJSON.first(where: { $0.id == index }) {
            return comic
        } else {
            return decodedJSON.last!
        }
    }

    
    func comic(withURL url: URL) -> ComicAPIEntity? {
        if let comic = decodedJSON.first(where: { $0.id == Int(url.pathComponents[1]) }) {
            return comic
        }
        return nil
    }
}

struct JSONPreviewLoader {
    static func load(fileName: String) -> Data? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                return data
            } catch {
                print("Could not load \(fileName)")
            }
        }
        return nil
    }
}
