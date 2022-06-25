//
//
//import SwiftUI
//
//struct ComicDetailsView: View {
//
//    @ObservedObject var viewModel: ComicListItemViewModel
//
//    var body: some View {
//        if (!viewModel.isLoading) {
//            VStack {
//                Text("\(viewModel.number) \(viewModel.title)")
//                    .font(.headline)
//
////                ComicView(image: $viewModel.image,
////                           description: $viewModel.alt)
//            }
//        } else {
//            ProgressView()
//        }
//
//    }
//
//}
//
//struct ComicsDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ComicDetailsView(viewModel: ComicListItemViewModel(preview: true))
//    }
//}
