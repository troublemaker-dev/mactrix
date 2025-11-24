import MatrixRustSDK
import SwiftUI
import OSLog

struct RoomContextMenu: View {
    @Environment(WindowState.self) var windowState

    let room: SidebarRoom

    var body: some View {
        if let roomInfo = room.roomInfo {
            Button {
                Task {
                    do {
                        Logger.viewCycle.info("marking room unread/read")
                        try await room.setUnreadFlag(newValue: !roomInfo.isMarkedUnread)
                    } catch {
                        Logger.viewCycle.error("failed to mark room unread/read: \(error)")
                    }
                }
            } label: {
                if roomInfo.isMarkedUnread {
                    Text("Mark as Read")
                } else {
                    Text("Mark as Unread")
                }
            }

            Button {
                Task {
                    do {
                        Logger.viewCycle.info("mark room favourite: \(!roomInfo.isFavourite)")
                        try await room.setIsFavourite(isFavourite: !roomInfo.isFavourite, tagOrder: nil)
                    } catch {
                        Logger.viewCycle.error("failed to mark room favourite: \(error)")
                    }
                }

            } label: {
                if roomInfo.isFavourite {
                    Label("Unfavorite", systemImage: "heart.slash")
                } else {
                    Label("Favorite", systemImage: "heart")
                }
            }
        }

        Button {
            Task {
                do {
                    Logger.viewCycle.info("leaving room: \(room.id())")
                    try await room.leave()
                    try await room.forget()

                    if windowState.selectedRoomId == room.id() {
                        windowState.selectedRoomId = nil
                    }
                } catch {
                    Logger.viewCycle.error("failed to leave room: \(error)")
                }
            }
        } label: {
            Label("Leave Room", systemImage: "minus.circle")
        }
    }
}
