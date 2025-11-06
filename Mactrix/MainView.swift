import SwiftUI
import MatrixRustSDK

struct RoomIcon: View {
    var body: some View {
        Rectangle()
            .aspectRatio(1.0, contentMode: .fit)
            .background(Color.blue)
    }
}

struct MainView: View {
    @Environment(AppState.self) var appState
    
    @State private var showWelcomeSheet: Bool = false
    @State private var inspectorVisible: Bool = false
    @State private var selectedCategory: SelectedCategory = .defaultCategory
    @State private var selectedRoomId: String? = nil
    
    var selectedRoom: Room? {
        guard let roomId = selectedRoomId else { return nil}
        return appState.matrixClient?.rooms.first(where: { $0.id() == roomId })
    }
    
    @ViewBuilder var details: some View {
        if let room = selectedRoom {
            ChatView(room: room).id(room.id)
        } else {
            ContentUnavailableView("Select a room", systemImage: "message.fill")
        }
    }
    
    var body: some View {
        NavigationSplitView(
            sidebar: { SidebarChannelView(selectedCategory: selectedCategory, selectedRoomId: $selectedRoomId) },
            detail: { details }
        )
        .inspector(isPresented: $inspectorVisible, content: {
            if let room = selectedRoom {
                RoomInspectorView(room: room, inspectorVisible: $inspectorVisible)
            } else {
                Text("No room selected")
            }
        })
        .task { await attemptLoadUserSession() }
        .sheet(isPresented: $showWelcomeSheet, onDismiss: onLoginModalDismiss ) {
            WelcomeSheetView()
        }
        .onChange(of: appState.matrixClient == nil) { _, matrixClientIsNil in
            if matrixClientIsNil {
                showWelcomeSheet = true
                selectedCategory = .defaultCategory
            }
        }
    }
    
    func attemptLoadUserSession() async {
        do {
            if let matrixClient = try await MatrixClient.attemptRestore() {
                appState.matrixClient = matrixClient
            }
        } catch {
            print(error)
        }
        
        showWelcomeSheet = appState.matrixClient == nil
        if let matrixClient = appState.matrixClient {
            onMatrixLoaded(matrixClient: matrixClient)
        }
    }
    
    func onMatrixLoaded(matrixClient: MatrixClient) {
        Task {
            try await matrixClient.startSync()
        }
    }
    
    func onLoginModalDismiss() {
        Task {
            try await Task.sleep(for: .milliseconds(100))
            if let matrixClient = appState.matrixClient {
                onMatrixLoaded(matrixClient: matrixClient)
            } else {
                NSApp.terminate(nil)
            }
        }
    }
}

#Preview {
    MainView()
}
