import SwiftUI

let channelsPerPage = 10

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var downloadedChannels: [PersonalChannel]
    
    @State private var currentTime: Date = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var channels: [(String, String, Color)] {
        var baseChannels: [(String, String, Color)] = [
            ("テレビの友チャンネル", "tv.fill", Color.blue),
            ("ニュースチャンネル", "newspaper.fill", Color.green),
            ("Wiiショッピングチャンネル", "bag.fill", Color.blue),
            ("みんなのニンテンドーチャンネル", "circlebadge.2", Color.gray),
            ("お天気チャンネル", "cloud.sun.fill", Color.blue)
        ]
        for channel in downloadedChannels {
            baseChannels.append((channel.name, channel.imageName, Color(hex: channel.color)))
        }
        return baseChannels
    }
    
    var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 4 : 2
        return Array(repeating: .init(.flexible()), count: count)
    }
    
    var pages: [[(String, String, Color)]] {
        var pages: [[(String, String, Color)]] = []
        let totalChannels = channels.count
        
        for i in stride(from: 0, to: totalChannels, by: channelsPerPage) {
            let endIndex = min(i + channelsPerPage, totalChannels)
            var pageChannels = Array(channels[i..<endIndex])
            let dummy = ("　", "", Color.gray.opacity(0.2))
            pageChannels.append(contentsOf: Array(repeating: dummy, count: max(0, channelsPerPage - pageChannels.count)))
            pages.append(pageChannels)
        }
        return pages
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TabView {
                    ForEach(pages.indices, id: \.self) { pageIndex in
                        let page = pages[pageIndex]
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(page.indices, id: \.self) { index in
                                let channel = page[index]
                                if channel.0 != "　" {
                                    NavigationLink(destination: getDestinationView(channelName: channel.0)) {
                                        ChannelIcon(name: channel.0, imageName: channel.1, color: channel.2)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    ChannelIcon(name: channel.0, imageName: channel.1, color: channel.2)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                ZStack(alignment: .top) {
                    Color.gray.opacity(0.35)
                        .frame(height: 180)
                        .ignoresSafeArea(edges: .bottom)
                    Rectangle()
                        .fill(Color(red: 0.3, green: 0.7, blue: 1.0))
                        .frame(height: 4)
                    VStack {
                        Spacer()
                        SevenSegmentClockView(currentTime: currentTime)
                            .onReceive(timer) { currentTime = $0 }
                        Spacer()
                    }
                    .frame(height: 180)
                }
            }
            .background(Color.white.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
    
    @ViewBuilder
    func getDestinationView(channelName: String) -> some View {
        switch channelName {
        case "テレビの友チャンネル": TVnotomo_ch()
        case "ニュースチャンネル": News_ch()
        case "Wiiショッピングチャンネル": WiiShop_ch(downloadedChannels: $downloadedChannels)
        case "みんなのニンテンドーチャンネル": Nintendo_ch()
        case "お天気チャンネル": Forecast_ch()
        case "チェスゲーム": Chess_wiiware()
        default: Text("\(channelName) チャンネル起動")
        }
    }
}

struct ChannelIcon: View {
    let name: String
    let imageName: String
    let color: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(color)
                .frame(width: 185, height: 95)
                .shadow(radius: 5)
            if name != "　" {
                VStack {
                    Image(systemName: imageName)
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    Text(name)
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - 灰色７セグメント風時計
struct SevenSegmentClockView: View {
    var currentTime: Date
    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "yyyy/MM/dd (E)"
        return f
    }()
    var body: some View {
        VStack(spacing: 4) {
            Text(dateFormatter.string(from: currentTime))
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundColor(Color.black.opacity(0.65))
            Text(timeFormatter.string(from: currentTime))
                .font(.system(size: 48, weight: .black, design: .monospaced))
                .foregroundColor(Color.black.opacity(0.85))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(downloadedChannels: .constant([]))
    }
}
