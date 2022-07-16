import SwiftUI

struct ControlBar: View {
    
    var text: String
    @Binding var altTapped: Bool
    let onShareTap: () -> Void
    
    var body: some View {
        HStack {
            Label(text, systemImage: "number")
                .font(.callout)
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button {
                    onShareTap()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }

                Button {
                    altTapped.toggle()
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
