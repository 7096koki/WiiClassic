// WiiShop_ch.swift

import SwiftUI

// MARK: - モデル
struct PersonalChannel: Codable, Identifiable {
    var id = UUID() // 'let' から 'var' に変更
    var name: String
    var imageName: String
    var color: String
}

// MARK: - メインビュー
struct WiiShop_ch: View {
    @Binding var downloadedChannels: [PersonalChannel]
    
    // ダウンロード可能なチャンネルのリスト
    let availableChannels: [PersonalChannel] = [
        PersonalChannel(name: "test", imageName: "car.fill", color: "orange"),
    ]
    
    var body: some View {
        VStack {
            HStack {
                // ショッピングバッグのアイコン
                Image(systemName: "cart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Wiiショッピングチャンネル・Wiiウェア")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.top, 50)
            
            // ダウンロード可能なチャンネルのリスト
            List(availableChannels, id: \.name) { channel in
                HStack {
                    Image(systemName: channel.imageName)
                        .font(.system(size: 30))
                        .foregroundColor(Color(channel.color))
                    
                    Text(channel.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        self.downloadChannel(channel)
                    }) {
                        Text("ダウンロード")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0, green: 1.0, blue: 1.0))
        .navigationTitle("Wiiショッピングチャンネル")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // チャンネルをダウンロードして保存する
    private func downloadChannel(_ channel: PersonalChannel) {
        // すでにダウンロード済みか確認
        if !downloadedChannels.contains(where: { $0.name == channel.name }) {
            // ダウンロード済みチャンネルリストに追加
            downloadedChannels.append(channel)
            
            // UserDefaultsに保存
            saveChannels()
            
            print("\(channel.name)をダウンロードしました。")
        }
    }
    
    // UserDefaultsにチャンネルを保存する
    private func saveChannels() {
        if let encoded = try? JSONEncoder().encode(downloadedChannels) {
            UserDefaults.standard.set(encoded, forKey: "downloadedChannels")
        }
    }
}
