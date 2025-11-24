import OSLog
import SwiftUI

@MainActor
public protocol ImageLoader {
    func loadImage(matrixUrl: String, size: CGSize?) async throws -> Image?
}

public struct AvatarImage<Preview: View>: View {
    let avatarUrl: String?
    let placeholder: () -> Preview
    let imageLoader: ImageLoader?

    public init(
        avatarUrl: String?,
        imageLoader: ImageLoader?,
        placeholder: @escaping () -> Preview = {
            Rectangle().foregroundStyle(Color.gray)
        }
    ) {
        self.avatarUrl = avatarUrl
        self.imageLoader = imageLoader
        self.placeholder = placeholder
    }

    @State private var avatar: Image? = nil

    @ViewBuilder
    var imageOrPlaceholder: some View {
        if let avatar = avatar {
            avatar.resizable()
        } else {
            placeholder()
        }
    }

    public var body: some View {
        GeometryReader { proxy in
            imageOrPlaceholder
                .aspectRatio(1.0, contentMode: .fit)
                .task(id: avatarUrl) {
                    guard let avatarUrl = avatarUrl else { return }

                    do {
                        avatar = try await imageLoader?.loadImage(matrixUrl: avatarUrl, size: proxy.size)
                    } catch {
                        Logger.viewCycle.error("failed to load avatar (\(avatarUrl): \(error)")
                    }
                }
        }
    }
}
