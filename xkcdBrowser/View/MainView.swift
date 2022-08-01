import SwiftUI

struct MainView: View {

    #if DEBUG
    @StateObject var comicsListViewModel = ComicGridViewModel(networkManager: MockNetworkManager())
    #else
    @StateObject var comicsListViewModel = ComicGridViewModel(networkManager: NetworkManager())
    #endif
    
    var body: some View {
        ComicGridView(viewModel: comicsListViewModel)
    }
}

