import SwiftUI

// MARK: - Main Settings View
struct SettingsView: View {
    @Binding var downloadedChannels: [PersonalChannel]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Wii風の薄いグレー背景
                Color(red: 0.92, green: 0.92, blue: 0.92)
                    .ignoresSafeArea()
                
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
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Wii Button Component
    func wiiSettingsButton(title: String, systemIcon: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26)
                .fill(color)
                .frame(width: 320, height: 200)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 4)
            
            VStack(spacing: 12) {
                Image(systemName: systemIcon)
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Data Management View
struct DataManagementView: View {
    @Binding var downloadedChannels: [PersonalChannel]
    
    // 定数設定
    let totalBlocks = 4096
    let systemReservedBlocks = 1 // システムデータ (灰色用)
    let preinstalledBlocks = 1      // 実際は1ブロック
    
    // UI用の最低表示幅（ブロック換算）
    // 150ブロック分あれば、高さ14に対してちょうど良い丸み（カプセル状）が維持される
    let minDisplayBlocks: Double = 150
    
    var userUsedBlocks: Int {
        downloadedChannels.reduce(0) { $0 + $1.blocks }
    }
    
    var totalUsedBlocks: Int {
        systemReservedBlocks + preinstalledBlocks + userUsedBlocks
    }
    
    var freeBlocks: Int {
        max(0, totalBlocks - totalUsedBlocks)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // --- ストレージ使用状況メーター ---
            VStack(spacing: 12) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("本体保存メモリ")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(freeBlocks)")
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                            Text(" ブロック空き")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                        }
                    }
                    Spacer()
                    Text("\(Int(totalBlocks > 0 ? (Double(totalUsedBlocks)/Double(totalBlocks)*100) : 0))%")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // --- 分割プログレスバー (境界を丸く & 最小幅を確保) ---
                GeometryReader { geo in
                    let width = geo.size.width
                    let blockToWidth = width / CGFloat(totalBlocks)
                    
                    // 1. システム予約領域 (灰色) の幅
                    let systemWidth = CGFloat(systemReservedBlocks) * blockToWidth
                    
                    // 2. プリインストール (シアン) の描画終了地点
                    // 実際の値が小さくても、見た目上は systemWidth + 150ブロック分 確保する
                    let preinstalledVisualBlocks = max(Double(preinstalledBlocks), minDisplayBlocks)
                    let preinstalledEndWidth = systemWidth + (CGFloat(preinstalledVisualBlocks) * blockToWidth)
                    
                    // 3. ユーザー使用量 (濃い青) の描画終了地点
                    // ユーザーデータも非常に小さい場合を考慮して、シアンの終了地点よりは必ず右に来るように調整
                    let userVisualBlocks = max(Double(userUsedBlocks), downloadedChannels.isEmpty ? 0 : minDisplayBlocks)
                    let totalEndWidth = preinstalledEndWidth + (CGFloat(userVisualBlocks) * blockToWidth)
                    
                    ZStack(alignment: .leading) {
                        // 背景 (空き容量)
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(white: 0.9))
                        
                        // 下層：全体（濃い青）
                        // ※データがある場合のみ描画
                        if totalUsedBlocks > 0 {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(red: 0.0, green: 0.4, blue: 0.8))
                                .frame(width: min(width, totalEndWidth))
                        }
                        
                        // 中層：プリインストールまで（シアン）
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 0.0, green: 0.8, blue: 1.0))
                            .frame(width: min(width, preinstalledEndWidth))
                        
                        // 上層：システムのみ（灰色）
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray)
                            .frame(width: min(width, systemWidth))
                    }
                }
                .frame(height: 14)
            }
            .padding(24)
            .background(Color.white)
            
            // --- チャンネル一覧 ---
            List {
                Section(header: Text("システム予約領域")) {
                    HStack {
                        Image(systemName: "cpu")
                            .foregroundColor(.gray)
                            .frame(width: 30)
                        Text("システムデータ")
                        Spacer()
                        Text("\(systemReservedBlocks) ブロック")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Image(systemName: "apps.iphone")
                            .foregroundColor(Color(red: 0.0, green: 0.8, blue: 1.0))
                            .frame(width: 30)
                        Text("プリインストールアプリ")
                        Spacer()
                        // ラベルには「実際の1ブロック」を表示
                        Text("\(preinstalledBlocks) ブロック")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("ダウンロード済みチャンネル")) {
                    if downloadedChannels.isEmpty {
                        Text("パーソナルチャンネルはありません")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(downloadedChannels) { channel in
                            HStack(spacing: 15) {
                                Image(systemName: channel.imageName)
                                    .foregroundColor(Color(red: 0.0, green: 0.4, blue: 0.8))
                                    .frame(width: 30)
                                
                                Text(channel.name)
                                Spacer()
                                Text("\(channel.blocks) ブロック")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete(perform: deleteChannel)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            
            Text("本アプリは、驚異の10ブロック未満で構成されています。w")
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
        }
        .background(Color(white: 0.96))
        .navigationTitle("データ管理")
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
// MARK: - Sub Views
struct WiiSystemSettingsView: View {
    var body: some View {
        Form {
            Section {
                NavigationLink(destination: AboutAppView()) {
                    Label("このアプリについて", systemImage: "info.circle")
                }
                NavigationLink(destination: CreditsView()) {
                    Label("制作クレジット", systemImage: "person.3")
                }
            }
        }
        .navigationTitle("Wii本体設定")
    }
}

struct CreditsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("制作クレジット").font(.largeTitle.bold())
                VStack(alignment: .leading, spacing: 8) {
                    Text("開発チーム").font(.headline)
                    Text("Wii愛好家(仮)").foregroundColor(.secondary)
                    Divider().padding(.vertical)
                    Text("製作者").font(.headline)
                    Text("7096koki(GitHub名)").foregroundColor(.secondary)
                    Text("Gemini 3 Flash(Wii愛好家の会員として)").foregroundColor(.secondary)
                    Divider().padding(.vertical)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
            }
            .padding()
        }
        .background(Color(white: 0.96))
        .navigationTitle("クレジット")
    }
}

struct AboutAppView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue).padding()
            VStack(alignment: .leading, spacing: 15) {
                Text("WiiClassic v1.4.0-alpha").font(.title2.bold())
                Text("このアプリは、Wiiのユーザー体験を再現するファンプロジェクトです。")
                Text("※本アプリは任天堂株式会社とは一切関係ありません。")
                    .font(.caption).foregroundColor(.red)
            }
            .padding().background(Color.white).cornerRadius(15)
            Spacer()
        }
        .padding().background(Color(white: 0.96))
        .navigationTitle("このアプリについて")
    }
}
