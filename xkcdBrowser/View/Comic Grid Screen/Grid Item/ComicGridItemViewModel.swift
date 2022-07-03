import SwiftUI


/// ViewModel for a grid item
class ComicGridItemViewModel: ObservableObject {

    @Published var comic: ComicItem

    private(set) var id: UUID
    var isFetching: Bool = true
    var num: Int {
        comic.num
    }
    
    init(comic: ComicItem) {
        self.comic = comic
//        self.id = comic.num
        self.id = UUID()
    }

    @MainActor
    func fetchImage() async {
        guard isFetching else { return }
        await comic.fetchImage()
        isFetching = false
    }
}

extension ComicGridItemViewModel: Identifiable {}

extension ComicGridItemViewModel: Hashable {
    static func == (lhs: ComicGridItemViewModel, rhs: ComicGridItemViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
