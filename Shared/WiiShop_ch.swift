import SwiftUI

// MARK: - モデル
struct PersonalChannel: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var imageName: String
    var color: String
    var description: String // チャンネルの説明を追加
    var fileSize: String // ブロックサイズを追加
}

// MARK: - チャンネル詳細ビュー（ダウンロードボタンはこの画面に配置）
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
            print("\(channel.name) をダウンロードしました")
        }
    }
    
    // UserDefaultsにチャンネルを保存
    private func saveChannels() {
        if let encoded = try? JSONEncoder().encode(downloadedChannels) {
            UserDefaults.standard.set(encoded, forKey: "downloadedChannels")
        }
    }
    
    var body: some View {
        ZStack {
            // 背景（Wiiショップの明るい青を意識）
            Color(hex: "00A0FF").ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // チャンネル情報エリア (ScrollViewで詳細を表示)
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // アイコン、タイトル、容量表示
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
                                
                                Text("Wiiチャンネル / \(channel.fileSize)")
                                    .font(.headline)
                                    .foregroundColor(Color.white.opacity(0.8))
                            }
                            Spacer()
                        }
                        
                        // 説明
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
                
                // ダウンロードボタン（画面下部固定エリア）
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
                            // Wiiショッピングらしいオレンジ色
                            .background(isDownloaded(channel) ? Color.gray : Color(hex: "FF6600"))
                            .cornerRadius(10)
                            .shadow(radius: isDownloaded(channel) ? 0 : 5)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .disabled(isDownloaded(channel))
                }
                // ボタンエリアの背景を少し濃い青にして区切りを明確に
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
    
    // ダウンロード可能なチャンネルに説明と容量を追加
    let availableChannels: [PersonalChannel] = [
        PersonalChannel(
            name: "チェスゲーム",
            imageName: "checkerboard.rectangle",
            color: "black",
            description: "シンプルながら奥深い対戦が楽しめるチェスゲームのチャンネルです。Wiiリモコンを使った直感的な操作で、友達や家族と白熱の頭脳戦を楽しもう",
            fileSize: "1ブロック"
        ),
        PersonalChannel(
            name: "マイペンケースクリエイター",
            imageName: "pencil",
            color: "green",
            description: "WiiClassic開発者である7096kokiがトンボ鉛筆の文房具が好きなので作ってみました。",
            fileSize: "1ブロック"
        ),
    ]
    
    var body: some View {
        // ナビゲーションを有効にするためNavigationViewで囲む
        NavigationView {
            VStack {
                // タイトルヘッダー
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
                .background(Color(hex: "0090E0")) // ヘッダーを濃い青に
                
                // チャンネルリスト
                List {
                    ForEach(availableChannels, id: \.id) { channel in
                        // NavigationLinkで詳細ビューへ遷移
                        NavigationLink(destination: ChannelDetailView(channel: channel, downloadedChannels: $downloadedChannels)) {
                            HStack {
                                Image(systemName: channel.imageName)
                                    .font(.system(size: 30))
                                    .foregroundColor(Color(channel.color))
                                
                                VStack(alignment: .leading) {
                                    Text(channel.name)
                                        .font(.headline)
                                    Text("容量: \(channel.fileSize)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                // ダウンロード済みの場合はチェックマークを表示
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
            // 全体の背景を明るい青に
            .background(Color(hex: "00BFFF").ignoresSafeArea())
            .navigationTitle("チャンネルリスト") // List画面のタイトル
        }
    }
    
    // ダウンロード済みか確認（List内でチェックマークを表示するため）
    private func isDownloaded(_ channel: PersonalChannel) -> Bool {
        downloadedChannels.contains(where: { $0.name == channel.name })
    }
    
}
