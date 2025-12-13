import SwiftUI

let channelsPerPage = 10

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var downloadedChannels: [PersonalChannel]
    
    @State private var currentTime: Date = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - 基本チャンネル
    var channels: [(String, String, Color)] {
        var base: [(String, String, Color)] = [
            ("テレビの友チャンネル", "tv.fill", Color.blue),
            ("ニュースチャンネル", "newspaper.fill", Color.green),
            ("Wiiショッピングチャンネル", "bag.fill", Color.blue),
            ("みんなのニンテンドーチャンネル", "circlebadge.2", Color.gray),
            ("お天気チャンネル", "cloud.sun.fill", Color.blue),
            ("写真チャンネル", "photo.on.rectangle.angled", Color.orange),
            ("きょうとあしたの占いﾗｯｷｰﾁｬﾝﾈﾙ", "star.circle.fill", Color.purple),
        ]
        
        for c in downloadedChannels {
            base.append((c.name, c.imageName, Color(hex: c.color)))
        }
        
        return base
    }
    
    // MARK: - Grid 設定
    var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 4 : 2
        return Array(repeating: .init(.flexible()), count: count)
    }
    
    // MARK: - ページ構成
    var pages: [[(String, String, Color)]] {
        var result: [[(String, String, Color)]] = []
        let total = channels.count
        
        for i in stride(from: 0, to: total, by: channelsPerPage) {
            let end = min(i + channelsPerPage, total)
            var page = Array(channels[i..<end])
            
            // 足りない枠 → ダミー枠を足す
            let dummy = ("DUMMY", "", Color.gray.opacity(0.25))
            page.append(contentsOf: Array(repeating: dummy,
                count: max(0, channelsPerPage - page.count)))
            
            result.append(page)
        }
        
        // ★ 空ページを 3 ページ追加
        let dummyEmpty = ("DUMMY", "", Color.gray.opacity(0.25))

        for _ in 0..<3 {
            result.append(Array(repeating: dummyEmpty, count: channelsPerPage))
        }

        
        return result
    }
    
    // MARK: - UI
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                
                VStack(spacing: 0) {
                    
                    TabView {
                        ForEach(pages.indices, id: \.self) { pageIndex in
                            let page = pages[pageIndex]
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(page.indices, id: \.self) { i in
                                    let channel = page[i]
                                    
                                    // ダミー枠
                                    if channel.0 == "DUMMY" {
                                        ChannelIcon(
                                            name: "",
                                            imageName: "",
                                            color: channel.2
                                        )
                                    }
                                    
                                    // 実チャンネル
                                    else {
                                        NavigationLink(destination: getDestinationView(channelName: channel.0)) {
                                            ChannelIcon(name: channel.0, imageName: channel.1, color: channel.2)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    Spacer().frame(height: 180) // 時計のスペース確保
                }
                
                // 下固定の時計 UI
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
                }
                .frame(height: 180)
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - 遷移
    @ViewBuilder
    func getDestinationView(channelName: String) -> some View {
        switch channelName {
        case "テレビの友チャンネル": TVnotomo_ch()
        case "ニュースチャンネル": News_ch()
        case "Wiiショッピングチャンネル":
            WiiShop_ch(downloadedChannels: $downloadedChannels)
        case "みんなのニンテンドーチャンネル": Nintendo_ch()
        case "お天気チャンネル": Forecast_ch()
        case "チェスゲーム": Chess_wiiware()
        case "写真チャンネル": Photo_ch()
        case "マイペンケースクリエイター": MyPencaseCreator()
        case "きょうとあしたの占いﾗｯｷｰﾁｬﾝﾈﾙ": TodayandTomorrow_ch()
        default:
            Text("\(channelName) チャンネル起動")
        }
    }
}

// MARK: - アイコン
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
            
            if !name.isEmpty {
                VStack {
                    if !imageName.isEmpty {
                        Image(systemName: imageName)
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    Text(name)
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - 時計
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
