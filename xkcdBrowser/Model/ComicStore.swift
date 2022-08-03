import Foundation
import RealmSwift

protocol Store: AnyObject {
    func add(_ comic: ComicModel)
}

final class ComicStore: Store {
    private let realm: Realm
    
    public private(set) var items: Results<ComicModel>
    public static let shared = ComicStore()
    
    private init() {
        realm = try! Realm()
        items = realm.objects(ComicModel.self).sorted(byKeyPath: "id", ascending: false)
    }
    
    func add(_ comic: ComicModel) {
        do {
            try realm.write {
                realm.add(comic)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
