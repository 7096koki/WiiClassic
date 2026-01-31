import SwiftUI

// MARK: - モデル
struct PersonalChannel: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var imageName: String
    var color: String
    var description: String
    var blocks: Int // Int型に統一
}

// MARK: - チャンネル詳細ビュー
struct ChannelDetailView: View {
    let channel: PersonalChannel
    @Binding var downloadedChannels: [PersonalChannel]
    
    // ダウンロード済みか確認
    private func isDownloaded(_ channel: PersonalChannel) -> Bool {
        downloadedChannels.contains(where: { $0.name == channel.name })
    }
    
    // チャンネルをダウンロードして保存
    private func downloadChannel(_ channel: PersonalChannel) {
        if !isDownloaded(channel) {
            downloadedChannels.append(channel)
            saveChannels()
        }
    }
    
    // UserDefaultsに保存
    private func saveChannels() {
        if let encoded = try? JSONEncoder().encode(downloadedChannels) {
            UserDefaults.standard.set(encoded, forKey: "downloadedChannels")
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "00A0FF").ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack(alignment: .top, spacing: 15) {
                            Image(systemName: channel.imageName)
                                .font(.system(size: 60))
                                .foregroundColor(Color(channel.color))
                                .frame(width: 80, height: 80)
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(15)
                                .shadow(radius: 5)
                            
                            VStack(alignment: .leading) {
                                Text(channel.name)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                
                                // fileSize を blocks に修正
                                Text("Wiiチャンネル / \(channel.blocks) ブロック")
                                    .font(.headline)
                                    .foregroundColor(Color.white.opacity(0.8))
                            }
                            Spacer()
                        }
                        
                        Text("チャンネル情報")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                        
                        Text(channel.description)
                            .font(.body)
                            .foregroundColor(.white)
                            .lineSpacing(5)
                    }
                    .padding()
                }
                
                VStack(spacing: 0) {
                    Divider().background(Color.white)
                    
                    Button(action: {
                        self.downloadChannel(channel)
                    }) {
                        Text(isDownloaded(channel) ? "ダウンロード済み" : "ダウンロード（0 Wiiポイント）")
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .foregroundColor(.white)
                            .background(isDownloaded(channel) ? Color.gray : Color(hex: "FF6600"))
                            .cornerRadius(10)
                            .shadow(radius: isDownloaded(channel) ? 0 : 5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .disabled(isDownloaded(channel))
                }
                .background(Color(hex: "0090E0"))
            }
        }
        .navigationTitle(channel.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Wiiショッピングチャンネル（リスト）
struct WiiShop_ch: View {
    @Binding var downloadedChannels: [PersonalChannel]
    
    let availableChannels: [PersonalChannel] = [
        PersonalChannel(
            name: "チェスゲーム",
            imageName: "checkerboard.rectangle",
            color: "black",
            description: "シンプルながら奥深い対戦が楽しめるチェスゲームのチャンネルです。",
            blocks: 1 // 引数名を blocks に修正
        ),
        PersonalChannel(
            name: "マイペンケースクリエイター",
            imageName: "pencil",
            color: "orange",
            description: "WiiClassic開発者である7096kokiがトンボ鉛筆の文房具が好きなので作ってみました。",
            blocks: 1 // 引数名を blocks に修正
        ),
        PersonalChannel(
            name: "地球儀チャンネル",
            imageName: "globe",
            color: "green",
            description: "いつかお天気チャンネルの地球儀に実装します。それまではこれをお楽しみください！",
            blocks: 44 // 引数名を blocks に修正
        ),
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    Text("Wiiショッピングチャンネル")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.top, 40)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "0090E0"))
                
                List {
                    ForEach(availableChannels, id: \.id) { channel in
                        NavigationLink(destination: ChannelDetailView(channel: channel, downloadedChannels: $downloadedChannels)) {
                            HStack {
                                Image(systemName: channel.imageName)
                                    .font(.system(size: 30))
                                    .foregroundColor(Color(channel.color))
                                
                                VStack(alignment: .leading) {
                                    Text(channel.name)
                                        .font(.headline)
                                    // fileSize を blocks に修正
                                    Text("容量: \(channel.blocks) ブロック")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                if isDownloaded(channel) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "00BFFF").ignoresSafeArea())
        }
    }
    
    private func isDownloaded(_ channel: PersonalChannel) -> Bool {
        downloadedChannels.contains(where: { $0.name == channel.name })
    }
}
