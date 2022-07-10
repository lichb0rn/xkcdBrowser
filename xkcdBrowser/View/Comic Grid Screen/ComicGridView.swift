import SwiftUI

struct ComicGridView: View {
    @ObservedObject var viewModel: ComicGridViewModel
    
    @State private var isRefreshing: Bool = false
    
    // List on iPhone and grid on iPad
    private let layout: [GridItem] = [
        GridItem(.adaptive(minimum: 300, maximum: .infinity), spacing: 4)
    ]
    
    private let spacing: CGFloat = 8
    private let horizontalPadding: CGFloat = 4
    
    var body: some View {
        NavigationView {
            ZStack {
                if !viewModel.hasError {
                    feedView
                        .navigationTitle("xkcd")
                        .navigationBarTitleDisplayMode(.inline)
                } else {
                    ErrorView()
                }
            }
            .background(
                Color("background")
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var feedView: some View {
        ScrollView {
            LazyVGrid(columns: layout, spacing: spacing) {
                ForEach(viewModel.feed) { itemViewModel in
                    NavigationLink(destination: ComicDetailsView(viewModel: ComicDetailsViewModel(comic: itemViewModel.comic))) {
                        ComicGridItemView(viewModel: itemViewModel)
                            .background(Color.white)
                            .padding(.horizontal, horizontalPadding)
                            .task {
                                await viewModel.fetchNextComics()
                            }
                    }
                }
            }
        }
        .refreshable {
            await viewModel.fetchLatests()
        }
        .task {
            await viewModel.fetchLatests()
        }
    }
}



struct ComicsListView_Previews: PreviewProvider {
    static var previews: some View {
        ComicGridView(viewModel: ComicGridViewModel(fetcher: MockFetcher()))
            .previewDevice("iPhone 13 Pro")
        
        ComicGridView(viewModel: ComicGridViewModel(fetcher: MockFetcher()))
            .previewDevice("iPad Pro (11-inch)")
    }
}


