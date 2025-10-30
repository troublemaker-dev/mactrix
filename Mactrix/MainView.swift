import SwiftUI

struct SpaceIcon: View {
    let selected: Bool
    
    var body: some View {
        ZStack {
            Text("A")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
            .aspectRatio(1.0, contentMode: .fit)
            .background(.red)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(NSColor.controlAccentColor).opacity(selected ? 1 : 0), lineWidth: 3)
            )
    }
}

struct RoomIcon: View {
    var body: some View {
        Rectangle()
            .aspectRatio(1.0, contentMode: .fit)
            .background(Color.blue)
    }
}

struct MainView: View {
    @State var searchField: String = ""
    
    let spaces = ["First Space", "Second Space", "Third Space"]
    @State private var selectedSpace: String = "First Space"
    
    let channels = ["First Channel", "Second Channel", "Third Channel"]
    @State private var selectedChannel: String = "First Channel"
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            List(spaces, id: \.self, selection: $selectedSpace) { space in
                SpaceIcon(selected: space == selectedSpace)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    .listRowBackground(Color.white)
            }
            .listStyle(.plain)
            .padding(.top, 6)
            .frame(width: 56)
            .background(Color(NSColor.controlBackgroundColor))
            .overlay( Divider()
                .frame(maxWidth: 1, maxHeight: .infinity)
                .background(Color(NSColor.separatorColor)), alignment: .trailing)
            
            NavigationSplitView {
                List(channels, id: \.self, selection: $selectedChannel) { channel in
                    HStack(alignment: .center) {
                        RoomIcon()
                            .frame(width: 32, height: 32)

                        VStack(alignment: .leading) {
                            Spacer()
                            Text(channel)
                            Spacer()
                            Divider()
                        }
                        
                        Spacer()
                    }
                    .frame(height: 48)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .listStyle(.plain)
            } detail: {
                Text("Details")
            }
            .toolbarColorScheme(.light, for: .windowToolbar)
            .toolbar(removing: .title)
        }
    }
}

#Preview {
    MainView()
}
