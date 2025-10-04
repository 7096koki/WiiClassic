// SettingsView.swift

import SwiftUI

struct SettingsView: View {
    @Binding var downloadedChannels: [PersonalChannel]
    
    var body: some View {
        Form {
            Section(header: Text("全般")) {
                NavigationLink(destination: AboutAppView()) {
                    Text("このアプリについて")
                }
            }
            
            Section(header: Text("データ管理")) {
                // ダウンロード済みチャンネルのリストを直接表示
                List {
                    ForEach(downloadedChannels, id: \.id) { channel in
                        HStack {
                            Image(systemName: channel.imageName)
                                .foregroundColor(Color(channel.color))
                            Text(channel.name)
                            Spacer()
                        }
                    }
                    .onDelete(perform: deleteChannel) // スワイプで削除を有効にする
                }
            }
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // チャンネルを削除するメソッド
    private func deleteChannel(offsets: IndexSet) {
        downloadedChannels.remove(atOffsets: offsets)
        saveChannels()
    }
    
    // UserDefaultsにチャンネルを保存する
    private func saveChannels() {
        if let encoded = try? JSONEncoder().encode(downloadedChannels) {
            UserDefaults.standard.set(encoded, forKey: "downloadedChannels")
        }
    }
}

// このアプリについて
struct AboutAppView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("WiiClassicについて")
                .font(.title)
                .fontWeight(.bold)
            Text("バージョン: v1.1.0-alpha")
            Text("開発者: WiiClassic作成所(仮)")
            Text("このアプリは、Wiiを現代のスマホという最先端機器に入れてみたいという一心で頑張って作っております。")
            Text("ニンテンドー、Wiiとは関係ないファンアプリです。")
        }
        .padding()
        .navigationTitle("このアプリについて")
        .navigationBarTitleDisplayMode(.inline)
    }
}
