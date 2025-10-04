// WiiClassicApp.swift
// WiiClassicApp.swift

import SwiftUI

@main
struct WiiClassicApp: App {
    @State private var downloadedChannels: [PersonalChannel] = []
    
    var body: some Scene {
        WindowGroup {
            TabView {
                // MARK: Wiiメニュー
                ContentView(downloadedChannels: $downloadedChannels)
                    .tabItem {
                        Image(systemName: "square.grid.2x2.fill")
                        Text("Wiiメニュー")
                    }
                
                // MARK: Wii伝言板
                WiiMessageBoardView()
                    .tabItem {
                        Image(systemName: "envelope.fill")
                        Text("Wii伝言板")
                    }
                
                // MARK: 設定
                SettingsView(downloadedChannels: $downloadedChannels)
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("設定")
                    }
            }
            .onAppear {
                self.loadChannels()
            }
        }
    }
    
    // UserDefaultsからチャンネルを読み込む
    private func loadChannels() {
        if let savedChannels = UserDefaults.standard.data(forKey: "downloadedChannels") {
            if let decodedChannels = try? JSONDecoder().decode([PersonalChannel].self, from: savedChannels) {
                self.downloadedChannels = decodedChannels
            }
        }
    }
}
