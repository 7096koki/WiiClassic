import SwiftUI

// MARK: - モデル
struct PersonalChannel: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var imageName: String
    var color: String
}

// MARK: - Wiiショッピングチャンネル
struct WiiShop_ch: View {
    @Binding var downloadedChannels: [PersonalChannel]
    
    // ダウンロード可能なチャンネル
    let availableChannels: [PersonalChannel] = [
        PersonalChannel(name: "チェスゲーム", imageName: "checkerboard.rectangle", color: "red")
    ]
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "cart.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                Text("Wiiショッピングチャンネル")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.top, 40)
            
            List(availableChannels, id: \.id) { channel in
                HStack {
                    Image(systemName: channel.imageName)
                        .font(.system(size: 30))
                        .foregroundColor(Color(channel.color))
                    
                    Text(channel.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    Button(action: {
                        self.downloadChannel(channel)
                    }) {
                        Text(isDownloaded(channel) ? "ダウンロード済み" : "ダウンロード")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(isDownloaded(channel) ? Color.gray : Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(isDownloaded(channel))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue)
        .navigationTitle("Wiiショッピングチャンネル")
        .navigationBarTitleDisplayMode(.inline)
    }
    
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
}
