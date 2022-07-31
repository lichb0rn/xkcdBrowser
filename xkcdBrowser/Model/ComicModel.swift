import Foundation
import RealmSwift


final class ComicModel: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id: ObjectId
    
    @Persisted var num: Int
    @Persisted var title: String
    @Persisted var alt: String
    @Persisted var imageURL: String
    @Persisted var cachedImageURL: String?
    @Persisted var isFavorite: Bool = false
    @Persisted var isViewed: Bool = false
}
