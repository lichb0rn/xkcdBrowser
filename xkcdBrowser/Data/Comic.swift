import SwiftUI

// A type that represents data in the grid
struct Comic: Codable {
    let id: Int
    let title: String
    let description: String
    let imageURL: URL
    var comicURL: URL
    
    var isViewed: Bool = false
    var isFavorite: Bool = false
    
    
    init(entity: ComicAPIEntity, url: URL) {
        self.id = entity.id
        self.title = entity.title
        self.description = entity.text
        self.imageURL = entity.imageUrl
        self.comicURL = url
    }
    
    mutating func markViewed() {
        isViewed = true
    }
}

extension Comic: Identifiable, Hashable {}
