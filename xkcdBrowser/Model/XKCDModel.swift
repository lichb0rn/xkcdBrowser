
import Foundation

struct XKCDComics {
    let number: Int
    let link: String
    let text: String
    let image: URL
    let title: String
}

extension XKCDComics: Decodable {
    private enum CodingKeys: String, CodingKey {
        case link, title
        case number = "num"
        case text = "alt"
        case image = "img"
    }
}

