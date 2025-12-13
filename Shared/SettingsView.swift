import SwiftUI

struct SettingsView: View {
    @Binding var downloadedChannels: [PersonalChannel]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                
                // --- Wii 本体設定 ---
                NavigationLink(destination: WiiSystemSettingsView()) {
                    wiiSettingsButton(
                        title: "Wii本体設定",
                        systemIcon: "gearshape.fill",
                        color: Color.blue
                    )
                }
                
                // --- データ管理 ---
                NavigationLink(destination: DataManagementView(downloadedChannels: $downloadedChannels)) {
                    wiiSettingsButton(
                        title: "データ管理",
                        systemIcon: "internaldrive.fill",
                        color: Color.orange
                    )
                }
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


// ===============================
// MARK: - Wii チャンネル風「正方形」ボタン
// ===============================
func wiiSettingsButton(title: String, systemIcon: String, color: Color) -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 26)
            .fill(color)
            .frame(width: 400, height: 300)  // ← 大きくした！
            .shadow(radius: 2)
        
        VStack(spacing: 12) {
            Image(systemName: systemIcon)
                .font(.system(size: 60))      // ← アイコンも拡大
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 18, weight: .bold))  // ← 文字サイズも拡大
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 6)
        }
    }
}

// ===============================
// MARK: - Wii本体設定（旧 全般）
// ===============================
struct WiiSystemSettingsView: View {
    var body: some View {
        Form {
            Section {
                NavigationLink(destination: AboutAppView()) {
                    Text("このアプリについて")
                }
                NavigationLink(destination: CreditsView()) {
                    Text("制作クレジット")
                }
            }
        }
        .navigationTitle("Wii本体設定")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// ===============================
// MARK: - データ管理
// ===============================
struct DataManagementView: View {
    @Binding var downloadedChannels: [PersonalChannel]
    
    var body: some View {
        Form {
            Section(header: Text("ダウンロード済みチャンネル")) {
                List {
                    ForEach(downloadedChannels, id: \.id) { channel in
                        HStack {
                            Image(systemName: channel.imageName)
                                .foregroundColor(Color(hex: channel.color))
                            Text(channel.name)
                            Spacer()
                        }
                    }
                    .onDelete(perform: deleteChannel)
                }
            }
        }
        .navigationTitle("データ管理")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func deleteChannel(offsets: IndexSet) {
        downloadedChannels.remove(atOffsets: offsets)
        saveChannels()
    }

    private func saveChannels() {
        if let encoded = try? JSONEncoder().encode(downloadedChannels) {
            UserDefaults.standard.set(encoded, forKey: "downloadedChannels")
        }
    }
}


// ===============================
// MARK: - 制作クレジット
// ===============================
struct CreditsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("制作クレジット")
                .font(.title)
                .fontWeight(.bold)
            
            Group {
                Text("開発チーム名:")
                Text(" - Wii愛好家(仮)")
                Text("スペシャルサンクス:")
                Text(" - クラスメイト10(仮)")
            }
            .padding(.leading)
            
            Spacer()
        }
        .padding()
        .navigationTitle("制作クレジット")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// ===============================
// MARK: - このアプリについて
// ===============================
struct AboutAppView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("WiiClassicについて")
                .font(.title)
                .fontWeight(.bold)
            Text("バージョン: v1.4.0-alpha")
            Text("開発者: Wii愛好家(仮)")
            Text("このアプリは、Wiiを現代のスマホという最先端機器に入れてみたいという一心で頑張って作っております。")
            Text("ニンテンドー、Wiiとは関係ないファンアプリです。")
        }
        .padding()
        .navigationTitle("このアプリについて")
        .navigationBarTitleDisplayMode(.inline)
    }
}
