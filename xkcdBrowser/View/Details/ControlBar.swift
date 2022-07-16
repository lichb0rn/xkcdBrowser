import SwiftUI

struct ControlBar: View {
    
    var text: String
    @Binding var altTouched: Bool
    
    var body: some View {
        HStack {
            Label(text, systemImage: "number")
                .font(.callout)
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button {
                    print("shared")
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }

                Button {
                    altTouched.toggle()
                } label: {
                    Image(systemName: "questionmark")
                        .font(.headline)
                }
            }
            .buttonStyle(.bordered)
            Spacer()
        }
    }
}
