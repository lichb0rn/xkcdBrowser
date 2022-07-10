import SwiftUI

struct ComicDetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: ComicDetailsViewModel
    
    var body: some View {
        VStack {
            viewModel.image
                .resizable()
                .aspectRatio(contentMode: .fit)
            
        }
        .padding()
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }

            }
            
            ToolbarItem {
                Button {
                    print(viewModel.text)
                } label: {
                    Image(systemName: "questionmark")
                }
            }
        })
        
    }
}

struct ComicsDetailsView_Previews: PreviewProvider {
    static let comicItem = ComicItem.preview.first!
    static let viewModel = ComicDetailsViewModel(comic: comicItem)
    
    static var previews: some View {
        NavigationView {
            ComicDetailsView(viewModel: viewModel)
        }
    }
}
