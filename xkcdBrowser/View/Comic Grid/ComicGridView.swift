import SwiftUI

struct ComicGridView: View {
    @EnvironmentObject var store: ComicStore
    
    var body: some View {
        NavigationView {
            feedView
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("xkcd")
                            .font(Settings.fontLarge)
                            .foregroundColor(.white)
                    }
                }
                .background(
                    Color("background")
                )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // List on iPhone and grid on iPad
    private let layout: [GridItem] = [
        GridItem(.adaptive(minimum: 300, maximum: .infinity), spacing: 4)
    ]
    
    private let spacing: CGFloat = 8
    private let horizontalPadding: CGFloat = 4
    var feedView: some View {
        ScrollView {
            LazyVGrid(columns: layout, spacing: spacing) {
                ForEach(store.comics) { comic in
                    NavigationLink(destination: ComicDetailsView(comic: comic)) {
                        ComicGridItemView(comic: comic)
                            .background(Color.white)
                            .padding(.horizontal, horizontalPadding)
                    }
                }
            }
        }
    }
}



struct ComicsListView_Previews: PreviewProvider {
    
    static let mockFetcher = Fetcher(networking: MockNetworking())
    
    static var previews: some View {
        Group {
            ComicGridView().environmentObject(ComicStore(fetcher: mockFetcher))
                .previewDevice("iPhone 13 Pro")
            
            ComicGridView().environmentObject(ComicStore(fetcher: mockFetcher))
                .previewDevice("iPad Pro (11-inch)")
        }
    }
}


