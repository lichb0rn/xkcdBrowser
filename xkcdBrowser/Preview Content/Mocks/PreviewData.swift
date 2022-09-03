import Foundation


/// Struct to contain pre-downloaded comics for preview and testing
struct PreviewData {
    // First file stars from 614 (614.json) and the last one is 633
    let startIndex = 614
    let endIndex = 633
    
    // Keeping borth `raw` data and decoded JSON for different puproses (preview and testing)
    var decodedJSON: [ComicAPIEntity] = []
    var data: [String:Data] = [:]
    
    init() {
        self.loadRawData()
    }
    
    mutating func loadRawData() {
        for idx in startIndex...endIndex {
            if let comicData = JSONPreviewLoader.load(fileName: "\(idx)")  {
                let key = "\(idx).json"
                data[key] = comicData
                if let json = try? JSONDecoder().decode(ComicAPIEntity.self, from: comicData) {
                    decodedJSON.append(json)
                }
            }
        }
    }
    
    func comicData() -> Data {
        return data.randomElement()!.value
    }
    
    func comic(withIndex index: Int) -> ComicAPIEntity {
        if let comic = decodedJSON.first(where: { $0.id == index }) {
            return comic
        } else {
            return decodedJSON.first!
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
