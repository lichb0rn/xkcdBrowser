import SwiftUI

struct MainView: View {

    @ObservedObject var comicsViewModel: ComicsViewModel

    init() {
        self.comicsViewModel = ComicsViewModel(imageService: ImageService())
    }

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Image(systemName: "tray.and.arrow.down.fill")
                    Text("Latest")
                }
                .environmentObject(comicsViewModel)
            
            ComicsListView()
                .tabItem {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("More")
                }
        }

    }
}

