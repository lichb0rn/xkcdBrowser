import SwiftUI

struct ComicGridItemView: View {
    
    @ObservedObject var viewModel: ComicGridItemViewModel
    
    @State private var opacity: Double = 0
    
    init(viewModel: ComicGridItemViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Group {
            if !viewModel.isFetching, let image = viewModel.image {
                comicView(image)
            } else {
                WaitingView()
            }
        }
        .border(.black, width: 2)
        .onAppear {
            if !viewModel.isFetching {
                opacity = 1
            }
        }
    }
    
    
    func comicView(_ image: Image) -> some View {
        return VStack(alignment: .center) {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .clipped()
                .aspectRatio(1, contentMode: .fit)
                .opacity(opacity)
                .animation(.easeInOut(duration: 1), value: opacity)
                .padding()
                .onAppear {
                    opacity = 1
                }
            
            Text(viewModel.title)
                .font(.body)
                .lineLimit(1)
            
                Text(viewModel.num)
                    .font(.footnote)
        }
    }
    

}

struct ComicsCardView_Previews: PreviewProvider {
    static var previews: some View {
        let comicItem = ComicItem.preview.first!
//        let viewModel = ComicGridItemViewModel(comic: comicItem)
        let viewModel = ComicGridItemViewModel(comic: comicItem, id: 0)

        return ComicGridItemView(viewModel: viewModel)
    }
}
