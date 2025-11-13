import SwiftUI

struct SettingsView: View {
    @Binding var downloadedChannels: [PersonalChannel]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("全般")) {
                    NavigationLink(destination: AboutAppView()) {
                        Text("このアプリについて")
                    }
                    // ここに制作クレジットへのリンクを追加
                    NavigationLink(destination: CreditsView()) {
                        Text("制作クレジット")
                    }
                }
                
                Section(header: Text("データ管理")) {
                    List {
                        ForEach(downloadedChannels, id: \.id) { channel in
                            HStack {
                                Image(systemName: channel.imageName)
                                    .foregroundColor(Color(channel.color))
                                Text(channel.name)
                                Spacer()
                            }
                        }
                        .onDelete(perform: deleteChannel)
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
        }
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

// 既存の AboutAppView はそのまま

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
