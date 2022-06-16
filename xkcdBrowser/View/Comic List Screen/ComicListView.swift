import SwiftUI

struct ComicListView: View {
    @ObservedObject var viewModel: ComicListViewModel

    @State private var isPresented: Bool = false
    @State private var selectedIndex: Int?

    private let layout: [GridItem] = [
        GridItem(.adaptive(minimum: 250), spacing: 8)
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
                ForEach(viewModel.feed, id: \.self) { itemViewModel in
                    ComicListItemView(viewModel: itemViewModel)
                        .background(Color.white)
                        .padding([.leading, .trailing], 4)
                        .shadow(radius: 2)
                        .task {
                            await viewModel.fetchMore(currentIndex: itemViewModel.comic.id)
                        }
                }
            }
            .task {
                await viewModel.fetchLatest()
            }
            .refreshable {
                await viewModel.fetchLatest()
            }
        }
    }
}



struct ComicsListView_Previews: PreviewProvider {
    static var previews: some View {
        ComicListView(viewModel: ComicListViewModel(imageService: MockImageService()))
            .previewDevice("iPhone 13 Pro")

        ComicListView(viewModel: ComicListViewModel(imageService: MockImageService()))
            .previewDevice("iPad Pro (11-inch)")
    }
}


