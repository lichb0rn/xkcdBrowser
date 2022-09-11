import SwiftUI

struct ComicGridView: View {
    @EnvironmentObject var store: ComicStore
    
    @State private var showBottomSheet: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: layout, spacing: spacing) {
                ForEach(store.comics) { comic in
                    NavigationLink(destination: ComicDetailsView(comic: comic)) {
                        ComicGridItemView(comic: comic)
                            .background(Color.white)
                            .padding(.horizontal, horizontalPadding)
                            .task {
                                await store.fetch(currentIndex: comic.id)
                            }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(action: {
                        // easter egg
                    }) {
                        Text("xkcd")
                            .font(Settings.fontLarge)
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showBottomSheet = true
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                    }
                    
                }
            }
            .confirmationDialog("", isPresented: $showBottomSheet) {
                Button("Clear cache", role: .destructive) {
                    print("clear")
                }
            }
        }
        .background(
            Color("background")
        )
    }
    
    // List on iPhone and grid on iPad
    private let layout: [GridItem] = [
        GridItem(.adaptive(minimum: 300, maximum: .infinity), spacing: 4)
    ]
    private let spacing: CGFloat = 8
    private let horizontalPadding: CGFloat = 4
}



struct ComicsListView_Previews: PreviewProvider {
    
    static let mockFetcher = Fetcher(networking: MockNetworking())
    
    static var previews: some View {
        Task {
            try await ComicService.shared.setUp(fetcher: mockFetcher, storage: DiskStorage())
        }
        return ComicGridView()
            .environmentObject(ComicStore(prefetchCount: 10,
                                          prefetchMargin: 5,
                                          comicService: ComicService.shared,
                                          imageDownloader: ImageService(fetcher: Fetcher())))
            .previewDevice("iPhone 13 Pro")
        
    }
}


