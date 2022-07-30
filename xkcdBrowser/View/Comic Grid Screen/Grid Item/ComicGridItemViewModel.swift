import SwiftUI


/// ViewModel for a grid item
class ComicGridItemViewModel: ObservableObject {

    private(set) var comic: ComicItem

    let id: Int

    @Published private(set) var isFetching: Bool = false
    var num: String {
        "\(comic.comicData.num)"
    }
    var title: String {
        comic.comicData.title
    }
    var image: Image? {
        comic.comicImage
    }
    
    var isViewed: Bool {
        comic.isViewed
    }
    
    init(comic: ComicItem, id: Int) {
        self.comic = comic
        self.id = id
    }


    @MainActor
    func fetchImage() async {
        guard !isFetching else { return }
        
        isFetching = true
        await comic.fetchImage()
        isFetching = false
    }
}

extension ComicGridItemViewModel: Identifiable {}
