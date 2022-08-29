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
    
    
    init(comicData: ComicAPIEntity, url: URL) {
        self.id = comicData.id
        self.title = comicData.title
        self.description = comicData.text
        self.imageURL = comicData.imageUrl
        self.comicURL = url
    }
    
    mutating func markViewed() {
        isViewed = true
    }
}

extension Comic: Identifiable, Hashable {}
