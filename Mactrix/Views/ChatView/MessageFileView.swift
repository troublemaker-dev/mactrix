import MatrixRustSDK
import Models
import OSLog
import QuickLook
import SwiftUI
import UniformTypeIdentifiers

struct MessageFileView: View {
    @Environment(AppState.self) private var appState
    let content: FileMessageContent

    @State private var icon: Image?
    @State private var fileHandle: MediaFileHandle?
    @State private var fileUrl: URL?
    @State private var quickLookUrl: URL?

    var mimeType: UTType? {
        guard let mimeStr = content.info?.mimetype, let mime = UTType(mimeStr) else {
            return nil
        }
        return mime
    }

    func previewFile() async {
        if let fileUrl {
            quickLookUrl = fileUrl
            return
        }

        guard let matrixClient = appState.matrixClient?.client else { return }

        do {
            let handle = try await matrixClient.getMediaFile(
                mediaSource: content.source,
                filename: content.filename,
                mimeType: content.info?.mimetype ?? "",
                useCache: true,
                tempDir: NSTemporaryDirectory()
            )
            fileHandle = handle

            let path = try handle.path()

            let fileUrl = URL(filePath: path, directoryHint: .notDirectory)
            self.fileUrl = fileUrl
            quickLookUrl = fileUrl

            let nsImage = NSWorkspace.shared.icon(forFile: path)
            icon = Image(nsImage: nsImage)

            Logger.viewCycle.debug("downloaded file \(fileUrl.absoluteString)")
        } catch {
            Logger.viewCycle.error("failed to download file: \(error)")
        }
    }

    var body: some View {
        VStack {
            Button {
                Task(operation: previewFile)
            } label: {
                if let icon {
                    icon.quickLookPreview($quickLookUrl)
                }
                Text(content.filename).textSelection(.enabled)
                if let fileSize = content.info?.size {
                    Text("(\(fileSize.formatted(.byteCount(style: .file))))")
                        .textSelection(.enabled)
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)

            if let caption = content.caption {
                Text(caption.formatAsMarkdown)
                    .textSelection(.enabled)
            }
        }
        .onChange(of: content.info?.mimetype, initial: true) { _, _ in
            let nsImage = NSWorkspace.shared.icon(for: mimeType ?? .item)
            icon = Image(nsImage: nsImage)
        }
    }
}
