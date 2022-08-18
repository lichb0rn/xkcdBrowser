
import Foundation



// Data returned from the xkcd server
struct ComicAPIEntity {
    var id: Int
    var text: String = ""
    var title: String = ""
    var imageUrl: URL
}

extension ComicAPIEntity: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id = "num"
        case title
        case imageUrl = "img"
        case text = "alt"
    }
}

extension ComicAPIEntity: Identifiable, Hashable {}
