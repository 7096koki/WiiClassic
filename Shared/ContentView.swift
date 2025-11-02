import SwiftUI

// 1ページあたりのチャンネル数 (2列の場合、5行で1ページで10個)
let channelsPerPage = 10

struct ContentView: View {

<<<<<<< HEAD
    @Environment(\.horizontalSizeClass) var horizontalSizeClass // 端末のサイズクラスを判定
    @Binding var downloadedChannels: [PersonalChannel] // @Bindingに変更
=======
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var downloadedChannels: [PersonalChannel]
>>>>>>> develop
    
    // MARK: - 時間管理
    @State private var currentTime: Date = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - チャンネルリスト
    var channels: [(String, String, Color)] {
        var baseChannels: [(String, String, Color)] = [
            ("テレビの友チャンネル", "tv.fill", Color.blue),
            ("ニュースチャンネル", "newspaper.fill", Color.green),
            ("Wiiショッピングチャンネル", "bag.fill", Color.blue),
<<<<<<< HEAD
=======
            ("みんなのニンテンドーチャンネル", "circlebadge.2", Color.gray),
            ("お天気チャンネル", "cloud.sun.fill", Color.blue),
>>>>>>> develop
        ]
        for channel in downloadedChannels {
            baseChannels.append((channel.name, channel.imageName, Color(hex: channel.color)))
        }
        return baseChannels
    }
    
    // MARK: - レイアウト構成
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
            
            // 足りない部分を空白で埋める
            let dummyName = "　"
            let dummyChannel = (dummyName, "", Color.gray.opacity(0.2))
            let dummyCount = channelsPerPage - pageChannels.count
            if dummyCount > 0 {
                pageChannels.append(contentsOf: Array(repeating: dummyChannel, count: dummyCount))
            }
            pages.append(pageChannels)
        }
        return pages
    }
    
    // MARK: - メインビュー
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // チャンネルページ
                TabView {
                    ForEach(pages.indices, id: \.self) { pageIndex in
                        let page = pages[pageIndex]
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(page.indices, id: \.self) { channelIndex in
                                let channel = page[channelIndex]
                                
                                if channel.0 != "　" {
                                    NavigationLink(destination: getDestinationView(channelName: channel.0)) {
                                        ChannelIcon(
                                            name: channel.0,
                                            imageName: channel.1,
                                            color: channel.2
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else {
                                    ChannelIcon(
                                        name: channel.0,
                                        imageName: channel.1,
                                        color: channel.2
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
<<<<<<< HEAD
                .padding()
                
                Spacer()
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
=======
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
                
                // MARK: - 下部フラットゾーン
                ZStack(alignment: .top) {
                    // 灰色ゾーン本体
                    Color.gray.opacity(0.35)
                        .frame(height: 180) // ← ここで少し伸ばした！
                        .ignoresSafeArea(edges: .bottom)
                    
                    // 水色ライン（境界線を太く）
                    Rectangle()
                        .fill(Color(red: 0.3, green: 0.7, blue: 1.0))
                        .frame(height: 4)
                        .frame(maxWidth: .infinity)
                        .edgesIgnoringSafeArea(.horizontal)
                    
                    // 時計（中央配置）
                    VStack {
                        Spacer()
                        SevenSegmentClockView(currentTime: currentTime)
                            .onReceive(timer) { input in
                                currentTime = input
                            }
                        Spacer()
                    }
                    .frame(height: 180)
                }
            }
            .background(Color.white.ignoresSafeArea())
            .navigationBarHidden(true)
>>>>>>> develop
        }
    }
    
    // MARK: - チャンネル遷移先
    @ViewBuilder
    func getDestinationView(channelName: String) -> some View {
        switch channelName {
<<<<<<< HEAD
        case "テレビの友チャンネル":
            TVnotomo_ch()
        case "ニュースチャンネル":
            News_ch()
        case "Wiiショッピングチャンネル":
            // ここで$downloadedChannelsを渡す
            WiiShop_ch(downloadedChannels: $downloadedChannels)
        default:
            EmptyView()
=======
        case "テレビの友チャンネル": TVnotomo_ch()
        case "ニュースチャンネル": News_ch()
        case "Wiiショッピングチャンネル": WiiShop_ch(downloadedChannels: $downloadedChannels)
        case "みんなのニンテンドーチャンネル": Nintendo_ch()
        case "お天気チャンネル": Forecast_ch()
        default:
            Text("\(channelName) チャンネル起動")
>>>>>>> develop
        }
    }
}

// MARK: - チャンネルアイコン
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

<<<<<<< HEAD
// プレビュープロバイダー
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // @Bindingのプレビューには.constant()を使用
        ContentView(downloadedChannels: .constant([]))
=======
// MARK: - 灰色７セグメント風時計 + 日付（黒っぽく）
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
                .shadow(color: .white.opacity(0.2), radius: 1, x: 0, y: 1)
        }
    }
}


// MARK: - プレビュー
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(downloadedChannels: .constant([]))
            .preferredColorScheme(.light)
>>>>>>> develop
    }
}
