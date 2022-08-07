import SwiftUI


/// ViewModel for a grid item
class ComicGridItemViewModel: ObservableObject {

    private(set) var comic: Comic

    let id: Int

    @Published var isViewed: Bool = false
    @Published private(set) var isFetching: Bool = false
    var num: String {
        "\(comic.comicData.id)"
    }
    var title: String {
        comic.comicData.title
    }
    var image: Image? {
        comic.comicImage
    }
    

    
    init(comic: Comic, id: Int) {
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
