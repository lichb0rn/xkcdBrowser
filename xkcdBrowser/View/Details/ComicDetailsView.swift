import SwiftUI

struct ComicDetailsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: ComicDetailsViewModel
    
    @State private var showPopup: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                viewModel.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Spacer()
                
                ControlBar(text: viewModel.num, altTapped: $showPopup) {
                    shareComic()
                }
            }
            .padding()
            
            if showPopup {
                GeometryReader { proxy in
                    PopupView(text: viewModel.text, isShowing: $showPopup)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                }
                
                
            }
        }
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
                .disabled(showPopup)
                
            }
        })
    }
    
    private func shareComic() {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        
        let share = UIActivityViewController(activityItems: [viewModel.linkForShare], applicationActivities: nil)
        windowScene?.keyWindow?.rootViewController?.present(share, animated: true, completion: nil)
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
