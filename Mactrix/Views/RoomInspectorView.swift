import SwiftUI
import MatrixRustSDK

struct RoomInspectorView: View {
    let room: Room
    @Binding var inspectorVisible: Bool
    
    var body: some View {
        VStack {
            Text("Room: \(room.id)")
        }
        .inspectorColumnWidth(min: 200, ideal: 250, max: 400)
        .toolbar {
            Spacer()
            Button {
                inspectorVisible.toggle()
            } label: {
                Label("Toggle Inspector", systemImage: "info.circle")
            }
        }
    }
}

