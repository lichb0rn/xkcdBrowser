import SwiftUI

struct MainView: View {

    @StateObject var imageService = ImageService()

    var body: some View {
        TabView {
            TodayView(viewModel: ComicsViewModel(imageService: imageService))
                .tabItem {
                    Image(systemName: "tray.and.arrow.down.fill")
                    Text("Latest")
                }

            
            ComicsListView(viewModel: ComicsListViewModel(imageService: imageService))
                .tabItem {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("More")
                }
        }
    }
}

