import SwiftUI

struct ControlsView: View {

    @Binding var index: Int
    @Binding var leftEnabled: Bool
    @Binding var rightEnabled: Bool

    var body: some View {
        HStack {
            Button {
                index -= 1
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(!leftEnabled)

            Spacer()

            Button {
                index += 1
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(!rightEnabled)
        }
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView(index: .constant(1000), leftEnabled: .constant(true), rightEnabled: .constant(false))
            .padding()
    }
}
