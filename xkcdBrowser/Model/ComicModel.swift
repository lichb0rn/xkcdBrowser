import Foundation
import RealmSwift
import UIKit

final class ComicModel: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var num: Int
    @Persisted var title: String
    @Persisted var alt: String
    @Persisted var imageURL: String
    @Persisted var cachedImageURL: String?
    @Persisted var isFavorite: Bool = false
    @Persisted var isViewed: Bool = false
    
    var image: UIImage?
        
    convenience init(xkcd: XKCDComic) {
        self.init()
        self.num = xkcd.num
        self.title = xkcd.title
        self.alt = xkcd.text
        self.imageURL = xkcd.imageUrl.absoluteString
    }
}

extension ComicModel {
    static var preview: [ComicModel] = {
        let previewData = PreviewData()
        var items: [ComicModel] = previewData.jsons.map { comic in
            var item = ComicModel(xkcd: comic)
            item.image = UIImage(contentsOfFile: comic.imageUrl.absoluteString)
            return item
        }
        return items
    }()
}
