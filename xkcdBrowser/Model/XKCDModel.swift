
import Foundation
import UIKit

struct XKCDComics {
    var number: Int = 0
    var link: String = ""
    var text: String = ""
    var imageURL: URL? = nil
    var title: String = ""
}

extension XKCDComics: Decodable {
    private enum CodingKeys: String, CodingKey {
        case link, title
        case number = "num"
        case text = "alt"
        case imageURL = "img"
    }
}

extension XKCDComics: Identifiable {
    var id: Int {
        return number
    }
}
