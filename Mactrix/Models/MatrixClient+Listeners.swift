import Foundation
import MatrixRustSDK
import OSLog
import UserNotifications

extension MatrixClient: @MainActor RoomListEntriesListener {
    func onUpdate(roomEntriesUpdate: [RoomListEntriesUpdate]) {
        for update in roomEntriesUpdate {
            switch update {
            case let .append(values):
                rooms.append(contentsOf: values.map(SidebarRoom.init(room:)))
            case .clear:
                rooms.removeAll()
            case let .pushFront(room):
                rooms.insert(SidebarRoom(room: room), at: 0)
            case let .pushBack(room):
                rooms.append(SidebarRoom(room: room))
            case .popFront:
                rooms.removeFirst()
            case .popBack:
                rooms.removeLast()
            case let .insert(index, room):
                rooms.insert(SidebarRoom(room: room), at: Int(index))
            case let .set(index, room):
                rooms[Int(index)] = SidebarRoom(room: room)
            case let .remove(index):
                rooms.remove(at: Int(index))
            case let .truncate(length):
                rooms.removeSubrange(Int(length) ..< rooms.count)
            case let .reset(values: values):
                rooms = values.map(SidebarRoom.init(room:))
            }
        }
    }
}

extension MatrixClient: @MainActor SyncServiceStateObserver {
    func onUpdate(state: MatrixRustSDK.SyncServiceState) {
        syncState = state
    }
}

extension MatrixClient: @MainActor VerificationStateListener {
    func onUpdate(status: MatrixRustSDK.VerificationState) {
        verificationState = status
    }
}

extension MatrixClient: @MainActor RoomListServiceStateListener {
    func onUpdate(state: MatrixRustSDK.RoomListServiceState) {
        roomListServiceState = state
    }
}

extension MatrixClient: @MainActor RoomListServiceSyncIndicatorListener {
    func onUpdate(syncIndicator: MatrixRustSDK.RoomListServiceSyncIndicator) {
        showRoomSyncIndicator = syncIndicator
    }
}

extension MatrixClient: @MainActor MatrixRustSDK.ClientDelegate {
    func didReceiveAuthError(isSoftLogout: Bool) {
        Logger.matrixClient.debug("did receive auth error: soft logout \(isSoftLogout, privacy: .public)")
        if !isSoftLogout {
            authenticationFailed = true
        }
    }
}

extension MatrixClient: @MainActor MatrixRustSDK.IgnoredUsersListener {
    func call(ignoredUserIds: [String]) {
        Logger.matrixClient.debug("Updated ignored users: \(ignoredUserIds)")
        self.ignoredUserIds = ignoredUserIds
    }
}

extension MatrixClient: @MainActor SessionVerificationControllerDelegate {
    func didReceiveVerificationRequest(details: MatrixRustSDK.SessionVerificationRequestDetails) {
        Logger.matrixClient.debug("session verification: didReceiveVerificationRequest")
        sessionVerificationRequest = details
    }

    func didAcceptVerificationRequest() {
        Logger.matrixClient.debug("session verification: didAcceptVerificationRequest")
    }

    func didStartSasVerification() {
        Logger.matrixClient.debug("session verification: didStartSasVerification")
    }

    func didReceiveVerificationData(data: MatrixRustSDK.SessionVerificationData) {
        Logger.matrixClient.debug("session verification: didReceiveVerificationData")
        sessionVerificationData = data
    }

    func didFail() {
        Logger.matrixClient.debug("session verification: didFail")
        sessionVerificationRequest = nil
        sessionVerificationData = nil
    }

    func didCancel() {
        Logger.matrixClient.debug("session verification: didCancel")
        sessionVerificationRequest = nil
        sessionVerificationData = nil
    }

    func didFinish() {
        Logger.matrixClient.debug("session verification: didFinish")
        sessionVerificationRequest = nil
        sessionVerificationData = nil
    }
}
