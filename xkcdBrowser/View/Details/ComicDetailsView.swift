import SwiftUI

struct ComicDetailsView: View {

    @ObservedObject var viewModel: ComicDetailsViewModel

    var body: some View {
        NavigationView {
                VStack {
                    viewModel.image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    Divider()
                    
                    Text(viewModel.text)
                        .font(.headline)
                }
                .padding()
                .navigationTitle(viewModel.num + viewModel.title)
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
}

struct ComicsDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        let comicItem = ComicItem.preview.first!
        let viewModel = ComicDetailsViewModel(comic: comicItem)
        
        ComicDetailsView(viewModel: viewModel)
    }
}
