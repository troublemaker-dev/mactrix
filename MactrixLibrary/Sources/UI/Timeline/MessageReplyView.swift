import SwiftUI

public struct MessageReplyView: View {
    let username: String
    let message: String
    let action: () -> Void

    public init(username: String, message: String, action: @escaping () -> Void = {}) {
        self.username = username
        self.message = message
        self.action = action
    }

    var content: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Reply: " + username)
                    .bold()
                    .textSelection(.enabled)
                Text(message.formatAsMarkdown)
                    .textSelection(.enabled)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(Color.gray.opacity(0.1))
        .italic()
    }

    public var body: some View {
        Button {
            action()
        } label: {
            content
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 10) {
        MessageReplyView(username: "user@example.com", message: "This is the root message")
        Text("Real content")
    }
}
