
import Foundation
import SwiftUI


// Data returned from server
struct XKCDComic {
    var num: Int
    var text: String = ""
    var title: String = ""
    var imageUrl: URL
    var link: URL {
        imageUrl.deletingLastPathComponent()
    }
}

extension XKCDComic: Decodable {
    private enum CodingKeys: String, CodingKey {
        case num
        case title
        case imageUrl = "img"
        case text = "alt"
    }
}

extension XKCDComic: Identifiable, Hashable {
    var id: Int {
        num
    }
}
