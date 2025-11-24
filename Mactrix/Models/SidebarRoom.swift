import Foundation
import MatrixRustSDK
import OSLog

@Observable
public final class SidebarRoom: MatrixRustSDK.Room {
    var roomInfo: RoomInfo?

    public convenience init(room: MatrixRustSDK.Room) {
        self.init(unsafeFromRawPointer: room.uniffiClonePointer())
    }

    required init(unsafeFromRawPointer pointer: UnsafeMutableRawPointer) {
        super.init(unsafeFromRawPointer: pointer)
        loadRoomInfo()
    }

    fileprivate func loadRoomInfo() {
        Task {
            do {
                self.roomInfo = try await self.roomInfo()
            } catch {
                Logger.viewCycle.error("Failed to load room info: \(error)")
            }
        }
    }
}
