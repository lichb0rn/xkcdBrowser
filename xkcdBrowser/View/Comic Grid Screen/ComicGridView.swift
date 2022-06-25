import SwiftUI

struct ComicGridView: View {
    @ObservedObject var viewModel: ComicGridViewModel

    @State private var isPresented: Bool = false
    @State private var selectedIndex: Int?

    // List on iPhone and grid on iPad
    private let layout: [GridItem] = [
        GridItem(.adaptive(minimum: 250), spacing: 8)
    ]

    private let spacing: CGFloat = 8
    private let horizontalPadding: CGFloat = 4

    var body: some View {
        NavigationView {
            ZStack {
                if !viewModel.hasError {
//                    feedView
                    adaptiveGrid
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
                    ComicGridItemView(viewModel: itemViewModel)
                        .background(Color.white)
                        .padding(.horizontal, horizontalPadding)
                        .task {
                            await viewModel.fetch(currentIndex: itemViewModel.id)
                        }
                }
            }
            .task {
                await viewModel.fetchLatests()
            }
            .refreshable {
                await viewModel.fetchLatests()
            }
        }
    }
    
    var adaptiveGrid: some View {
        AdaptiveGrid(gridItems: viewModel.feed) { itemViewModel in
            ComicGridItemView(viewModel: itemViewModel)
                .padding(.horizontal, horizontalPadding)
                .background(Color.white)
                .task {
                    await viewModel.fetch(currentIndex: itemViewModel.id)
                }
        }
        .task {
            await viewModel.fetchLatests()
        }
        .refreshable {
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


