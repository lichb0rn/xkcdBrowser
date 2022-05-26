import SwiftUI

struct ComicsView: View {
    
    @Binding var title: String
    @Binding var image: UIImage
    @Binding var description: String
    
    var body: some View {
        VStack {
            VStack {
                Text(title)
                    .font(.headline)
                    .padding()

                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
            Text(description)
                .font(.footnote)
                .foregroundColor(.gray)
                .padding()
        }
    }
}
