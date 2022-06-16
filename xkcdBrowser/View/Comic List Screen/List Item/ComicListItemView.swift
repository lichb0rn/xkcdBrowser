import SwiftUI

struct ComicListItemView: View {
    
    @ObservedObject var viewModel: ComicListItemViewModel
    
    var body: some View {
        viewModeledView
    }
    
    
    var viewModeledView: some View {
        VStack(alignment: .center) {
            if !viewModel.isLoading {
                viewModel.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
            } else {
                Spacer()
                Image("error")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        ZStack {
                            Color.black.opacity(0.5)
                            ProgressView()
                        }
                    )
                Spacer()
            }
            
            Text(viewModel.title)
                .font(.body)
                .lineLimit(1)
            
            Text(viewModel.number)
                .font(.footnote)
            
        }
        .border(.black, width: 2)
        .task {
            await viewModel.fetch()
        }
    }
}

struct ComicsCardView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ComicListItemViewModel(preview: true)

        return ComicListItemView(viewModel: viewModel)
            .frame(width: 350, height: 400, alignment: .center)
            .padding()
    }
}
