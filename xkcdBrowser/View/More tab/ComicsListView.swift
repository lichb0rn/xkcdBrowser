import SwiftUI

struct ComicsListView: View {
    
    @ObservedObject var viewModel: ComicsListViewModel
    
    private let layout: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: layout, alignment: .center, spacing: 8) {
                ForEach((1..<viewModel.maxNumber).reversed(), id: \.self) { index in
                    ComicsCardView(viewModel: viewModel.cardViewModel(for: index))
                        .frame(height: 180)
                }
            }
            .padding(.horizontal, 8)
        }
        .alert("Error", isPresented: $viewModel.hasError, actions: {
            Button(":(", role: .cancel) { }
        }, message: {
            Text(viewModel.errorDescription)
        })
    }
}


struct ComicsListView_Previews: PreviewProvider {
    static var previews: some View {
        ComicsListView(viewModel: ComicsListViewModel(imageService: MockImageService()))
    }
}
