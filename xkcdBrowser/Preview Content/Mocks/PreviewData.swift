import Foundation


/// Mock struct to contain pre-downloaded comics for preview and testing
struct PreviewData {
    /// First file stars from 614 (614.json) and the last one is 633
    let startIndex = 614
    let endIndex = 633
    
    var jsons: [ComicAPIEntity] = []
    
    init() {
        self.load()
    }
    
    mutating func load() {
        for idx in startIndex...endIndex {
            if let comic = JSONPreviewLoader.load(fileName: "\(idx)")  {
                jsons.append(comic)
            }
        }
    }
    
    func comic(withIndex index: Int) -> ComicAPIEntity {
        if let comic = jsons.first(where: { $0.id == index }) {
            return comic
        } else {
            return jsons.last!
        }
    }
    
    func comic(withURL url: URL) -> ComicAPIEntity {
        if let comic = jsons.first(where: { $0.link == url }) {
            return comic
        } else {
            return jsons.last!
        }
    }
}

struct JSONPreviewLoader {
    static func load(fileName: String) -> ComicAPIEntity? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                return try JSONDecoder().decode(ComicAPIEntity.self, from: data)
            } catch {
                print("Could not load \(fileName)")
            }
        }
        return nil
    }
}
