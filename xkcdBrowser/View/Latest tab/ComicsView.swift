import SwiftUI

struct ComicsView: View {
    
    @Binding var image: UIImage
    @Binding var description: String
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text(description)
                .font(.footnote)
                .foregroundColor(.gray)
                .padding()
        }
    }
}
