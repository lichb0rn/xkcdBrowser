import SwiftUI

struct ComicView: View {
    
    @Binding var image: Image
    @Binding var description: String
    
    var body: some View {
        VStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text(description)
                .font(.footnote)
                .foregroundColor(.gray)
                .padding()
        }
    }
}
