import Foundation
import MatrixRustSDK
import Models
import OSLog

@Observable
public final class LiveRoom: Identifiable {
    let sidebarRoom: SidebarRoom

    public var typingUserIds: [String] = []
    public var fetchedMembers: [MatrixRustSDK.RoomMember]?

    private var typingHandle: TaskHandle?

    public var room: MatrixRustSDK.Room {
        sidebarRoom.room
    }

    public var roomInfo: MatrixRustSDK.RoomInfo? {
        sidebarRoom.roomInfo
    }

    public var id: String {
        room.id()
    }

    public init(sidebarRoom: SidebarRoom) {
        self.sidebarRoom = sidebarRoom
    }

    public convenience init(matrixRoom: MatrixRustSDK.Room) {
        self.init(sidebarRoom: SidebarRoom(room: matrixRoom))
    }

    fileprivate func startListening() {
        typingHandle = room.subscribeToTypingNotifications(listener: self)
    }
}

extension LiveRoom: TypingNotificationsListener {
    public func call(typingUserIds: [String]) {
        self.typingUserIds = typingUserIds
    }
}

extension LiveRoom: Hashable {
    public static func == (lhs: LiveRoom, rhs: LiveRoom) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension LiveRoom: Models.Room {
    public func syncMembers() async throws {
        // guard not already synced
        guard fetchedMembers == nil else { return }

        let id = self.id
        Logger.liveRoom.debug("syncing members for room: \(id)")

        let memberIter = try await room.members()
        var result = [MatrixRustSDK.RoomMember]()
        while let memberChunk = memberIter.nextChunk(chunkSize: 1000) {
            result.append(contentsOf: memberChunk)
        }
        fetchedMembers = result

        Logger.liveRoom.debug("synced \(result.count) members")
    }

    public var displayName: String? {
        room.displayName()
    }

    public var topic: String? {
        room.topic()
    }

    public var encryptionState: Models.EncryptionState {
        room.encryptionState().asModel
    }
}
