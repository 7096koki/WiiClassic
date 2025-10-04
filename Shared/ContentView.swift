// ContentView.swift

import SwiftUI

struct ContentView: View {

    @Environment(\.horizontalSizeClass) var horizontalSizeClass // 端末のサイズクラスを判定
    @Binding var downloadedChannels: [PersonalChannel] // @Bindingに変更
    
    // チャンネルリスト
    var channels: [(String, String, Color)] {
        var baseChannels: [(String, String, Color)] = [
            ("テレビの友チャンネル", "tv.fill", Color.blue),
            ("ニュースチャンネル", "newspaper.fill", Color.green),
            ("Wiiショッピングチャンネル", "bag.fill", Color.blue),
        ]
        
        // ダウンロード済みチャンネルを追加
        for channel in downloadedChannels {
            baseChannels.append((channel.name, channel.imageName, Color(channel.color)))
        }
        
        return baseChannels
    }
    
    // 画面に応じて列数を変更
    var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 4 : 2 // iPadなら4列、iPhoneなら2列
        return Array(repeating: .init(.flexible()), count: count)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("WiiClassic")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .padding(.top, 50)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(channels, id: \.0) { channel in
                        NavigationLink(destination: getDestinationView(channelName: channel.0)) {
                            ChannelIcon(
                                name: channel.0,
                                imageName: channel.1,
                                color: channel.2
                            )
                        }
                    }
                    
                    // ダミーチャンネルを配置
                    ForEach(0..<6, id: \.self) { _ in
                        ChannelIcon(
                            name: "　",
                            imageName: "",
                            color: .gray.opacity(0.2)
                        )
                    }
                }
                .padding()
                
                Spacer()
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    // チャンネル名に応じて遷移先のViewを返す
    @ViewBuilder
    func getDestinationView(channelName: String) -> some View {
        switch channelName {
        case "テレビの友チャンネル":
            TVnotomo_ch()
        case "ニュースチャンネル":
            News_ch()
        case "Wiiショッピングチャンネル":
            // ここで$downloadedChannelsを渡す
            WiiShop_ch(downloadedChannels: $downloadedChannels)
        default:
            EmptyView()
        }
    }
}

// チャンネルアイコンのビュー
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
            } else {
                // ダミーチャンネルの場合
                Text(name)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// プレビュープロバイダー
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // @Bindingのプレビューには.constant()を使用
        ContentView(downloadedChannels: .constant([]))
    }
}
