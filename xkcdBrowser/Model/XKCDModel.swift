
import Foundation
import UIKit

struct XKCDComic {
    var id: Int
    var text: String = ""
    var imageUrl: URL
    var title: String = ""

    var link: URL {
        imageUrl.deletingLastPathComponent()
    }
}

extension XKCDComic: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id = "num"
        case title
        case imageUrl = "img"
        case text = "alt"
    }
}

extension XKCDComic: Identifiable {}
