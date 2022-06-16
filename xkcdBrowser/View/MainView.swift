import SwiftUI

struct MainView: View {

    @StateObject var imageService = ImageService.shared

    @StateObject var comicsListViewModel = ComicListViewModel(imageService: ImageService.shared)
//    @StateObject var comicsListViewModel = ComicListViewModel(store: ComicStore.shared)

    var body: some View {
        ComicListView(viewModel: comicsListViewModel)
    }
}

