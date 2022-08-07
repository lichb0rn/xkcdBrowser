import Foundation
import RealmSwift
import UIKit

final class ComicDBEntity: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var num: Int
    @Persisted var title: String
    @Persisted var alt: String
    @Persisted var imageURL: String
    @Persisted var cachedImageURL: String?
    @Persisted var isFavorite: Bool = false
    @Persisted var isViewed: Bool = false
    
    var image: UIImage?
        
    convenience init(xkcd: ComicAPIEntity) {
        self.init()
        self.num = xkcd.id
        self.title = xkcd.title
        self.alt = xkcd.text
        self.imageURL = xkcd.imageUrl.absoluteString
    }
}

extension ComicDBEntity {
    static var preview: [ComicDBEntity] = {
        let previewData = PreviewData()
        var items: [ComicDBEntity] = previewData.jsons.map { comic in
            var item = ComicDBEntity(xkcd: comic)
            item.image = UIImage(contentsOfFile: comic.imageUrl.absoluteString)
            return item
        }
        return items
    }()
}
