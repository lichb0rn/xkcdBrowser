//import SwiftUI
//
//struct TodayView: View {
//    
//    @ObservedObject var viewModel: ComicViewModel
//
//    var body: some View {
//        NavigationView {
//            VStack {
////                ComicView(image: $viewModel.image,
////                           description: $viewModel.alt)
////                .padding()
////                .navigationTitle(viewModel.title + " #\(viewModel.currentIndex)")
////                .navigationBarTitleDisplayMode(.inline)
//
//                Spacer()
//                ControlsView(
//                    index: $viewModel.currentIndex,
//                    leftEnabled: $viewModel.hasOldComics,
//                    rightEnabled: $viewModel.hasNewComics
//                )
//                .padding()
//            }
//            .overlay(progressOverlay)
//            .alert("Error", isPresented: $viewModel.hasError, actions: {
//                Button(":(", role: .cancel) { }
//            }, message: {
//                Text(viewModel.errorDescription)
//            })
//            .task {
//                await viewModel.fetchCurrent()
//            }
//        }
//        .navigationViewStyle(StackNavigationViewStyle())
//    }
//
//    @ViewBuilder private var progressOverlay: some View {
//        if viewModel.isLoading {
//            ProgressView()
//        }
//    }
//}
//
//
