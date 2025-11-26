import Models
import SwiftUI

public struct UserProfileRow<Profile: UserProfile>: View {
    let profile: Profile
    let imageLoader: ImageLoader?

    @State private var image: Image? = nil

    public init(profile: Profile, imageLoader: ImageLoader?) {
        self.profile = profile
        self.imageLoader = imageLoader
    }

    public var body: some View {
        Label {
            Text(profile.displayName ?? profile.userId)
                .lineLimit(1)
                .truncationMode(.tail)
                .help(profile.displayName ?? profile.userId)
        } icon: {
            AvatarImage(avatarUrl: profile.avatarUrl, imageLoader: imageLoader, placeholder: { Image(systemName: "person") })
                .clipShape(Circle())
        }
    }
}

public struct UserProfileRowLarge<Profile: UserProfile>: View {
    let profile: Profile
    let imageLoader: ImageLoader?

    public init(profile: Profile, imageLoader: ImageLoader?) {
        self.profile = profile
        self.imageLoader = imageLoader
    }

    public var body: some View {
        HStack {
            AvatarImage(avatarUrl: profile.avatarUrl, imageLoader: imageLoader)
                .frame(width: 32, height: 32)
                .clipShape(.circle)
            VStack(alignment: .leading) {
                Text(profile.displayName ?? "No display name")
                Text(profile.userId)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

#Preview {
    List {
        UserProfileRow(profile: MockUserProfile(), imageLoader: nil)
        UserProfileRow(profile: MockUserProfile(), imageLoader: nil)
        UserProfileRow(profile: MockUserProfile(), imageLoader: nil)
        
        UserProfileRowLarge(profile: MockUserProfile(), imageLoader: nil)
        UserProfileRowLarge(profile: MockUserProfile(), imageLoader: nil)
        UserProfileRowLarge(profile: MockUserProfile(), imageLoader: nil)
    }
    .frame(width: 250)
}
