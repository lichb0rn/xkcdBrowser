import SwiftUI

struct ComicsCardView: View {

    @ObservedObject var viewModel: CardViewModel

    var body: some View {
        VStack(alignment: .center) {
            if(!viewModel.isLoading) {
                Image(uiImage: viewModel.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                Text(viewModel.title)
                    .font(.body)
                    .lineLimit(1)

                Text(viewModel.number)
                    .font(.footnote)

            } else {
                ProgressView()
            }
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.black)
        )
        .padding(8)
        .task {
            await viewModel.fetch()
        }
    }

}

struct ComicsCardView_Previews: PreviewProvider {
    static var previews: some View {
        ComicsCardView(
            viewModel: CardViewModel(index: 614,
                                     imageService: MockImageService(),
                                     fetcher: MockComicsFetcher())
        )
        .previewLayout(.sizeThatFits)
    }
}
