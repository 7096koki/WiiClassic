// NintendoChannelView.swift

import SwiftUI
import WebKit

// MARK: - モデル（動画）
struct Video: Identifiable {
    let id = UUID()
    let title: String
    let youtubeURL: String
}

// MARK: - モデル（ソフト）
struct Game: Identifiable {
    let id = UUID()
    let title: String
    let platform: String
    let releaseDate: String
    let description: String
}

// MARK: - 動画再生ビュー
struct VideoPlayerView: View {
    let video: Video
    
    var body: some View {
        VStack {
            Text(video.title)
                .font(.headline)
                .padding()
            
            WebView(url: video.youtubeURL)
        }
        .navigationTitle(video.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - みんなのニンテンドーチャンネル（動画リスト）
struct Nintendoch_VideoView: View {
    private let videos: [Video] = [
        Video(title: "Nintendo Switch 紹介映像", youtubeURL: "https://www.youtube.com/embed/Jj4sfry-wYw?gl=JP"),
        Video(title: "Nintendo Switch 2 紹介映像", youtubeURL: "https://www.youtube.com/embed/oCc6N_EoT44?gl=JP")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.red
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .padding(.leading)
                        
                        Text("みんなのニンテンドーチャンネル")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 10)
                    
                    List {
                        ForEach(videos) { video in
                            NavigationLink(destination: VideoPlayerView(video: video)) {
                                Text(video.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
    }
}

// MARK: - ソフト詳細ビュー
struct GameDetailView: View {
    let game: Game
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // タイトル
                Text(game.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                // 発売日とプラットフォーム
                VStack(alignment: .leading, spacing: 6) {
                    Text("発売日：\(game.releaseDate)")
                    Text("プラットフォーム：\(game.platform)")
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                
                Divider()
                    .padding(.vertical, 8)
                
                // ゲーム紹介
                Text("ゲーム紹介")
                    .font(.headline)
                
                Text(game.description)
                    .font(.body)
                    .padding(.bottom, 30)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(game.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - プラットフォーム別ソフト一覧
struct PlatformGameListView: View {
    let platform: String
    let games: [Game]
    
    var body: some View {
        List {
            ForEach(games) { game in
                NavigationLink(destination: GameDetailView(game: game)) {
                    HStack {
                        Image(systemName: "gamecontroller")
                            .foregroundColor(.gray)
                        Text(game.title)
                    }
                }
            }
        }
        .navigationTitle(platform)
    }
}

// MARK: - プラットフォーム選択ビュー
struct PlatformSelectView: View {
    private let games: [Game] = [
        // ファミコン
        Game(title: "スーパーマリオブラザーズ", platform: "ファミコン", releaseDate: "1985/09/13", description: "横スクロールアクションの金字塔。マリオがクッパからピーチ姫を救う冒険へ！"),
        Game(title: "ゼルダの伝説", platform: "ファミコン", releaseDate: "1986年2月21日", description: "広大なハイラルを冒険するアクションRPGの原点。"),
        
        // スーパーファミコン
        Game(title: "スーパーマリオワールド", platform: "スーパーファミコン", releaseDate: "1990年11月21日", description: "ヨッシーと共に恐竜ランドを冒険する2Dアクションの決定版。"),
        Game(title: "星のカービィ スーパーデラックス", platform: "スーパーファミコン", releaseDate: "1996/03/21", description: "多彩なコピー能力で敵を倒すカービィの傑作アクション。"),
        
        // N64
        Game(title: "スーパーマリオ64", platform: "NINTENDO64", releaseDate: "1996/06/23", description: "3Dアクションの金字塔。箱庭世界を自由に冒険！"),
        Game(title: "ゼルダの伝説 時のオカリナ", platform: "NINTENDO64", releaseDate: "1998/11/21", description: "シリーズ屈指の名作。時を超える冒険が今、始まる。"),
        
        // GC
        Game(title: "スーパーマリオサンシャイン", platform: "ゲームキューブ", releaseDate: "2002/07/19", description: "マリオがホバーを使って南国の島を大冒険。"),
        Game(title: "ピクミン", platform: "ゲームキューブ", releaseDate: "2001/10/26", description: "不思議な生物ピクミンを率いて惑星探索！"),
        
        // Wii
        Game(title: "Wii Sports", platform: "Wii", releaseDate: "2006/12/02", description: "Wiiリモコンで体感！誰でも楽しめるスポーツゲーム。"),
        Game(title: "ゼノブレイド", platform: "Wii", releaseDate: "2010/06/10", description: "巨大な神の骸の上で繰り広げられる壮大なRPG。"),
        
        // Wii U
        Game(title: "スプラトゥーン", platform: "Wii U", releaseDate: "2015/05/28", description: "インクで陣地を塗り合う4対4の対戦アクション。"),
        Game(title: "スーパーマリオ 3Dワールド", platform: "Wii U", releaseDate: "2013/11/21", description: "4人で遊べる3Dマリオ！ネコマリオになって駆け回れ！"),
        
        // Switch
        Game(title: "ゼルダの伝説 ブレス オブ ザ ワイルド", platform: "Nintendo Switch", releaseDate: "2017/03/03日", description: "広大なハイラルを自由に探索できるオープンワールドRPG。"),
        Game(title: "スーパーマリオオデッセイ", platform: "Nintendo Switch", releaseDate: "2017/10/27日", description: "帽子“キャッピー”と共に世界を旅する3Dアクション。"),
    ]
    
    private let platformOrder: [String] = [
        "ファミコン",
        "スーパーファミコン",
        "NINTENDO64",
        "ゲームキューブ",
        "Wii",
        "Wii U",
        "Nintendo Switch",
        "Nintendo Switch 2",
        "スマートフォン用アプリ",
    ]
    
    var body: some View {
        List {
            ForEach(platformOrder, id: \.self) { platform in
                let filtered = games.filter { $0.platform == platform }
                if !filtered.isEmpty {
                    NavigationLink(destination: PlatformGameListView(platform: platform, games: filtered)) {
                        HStack {
                            Image(systemName: "square.stack.fill")
                                .foregroundColor(.blue)
                            Text(platform)
                                .font(.headline)
                        }
                    }
                }
            }
        }
        .navigationTitle("プラットフォーム一覧")
    }
}

// MARK: - ソフトを探す（トップ画面）
struct SoftwareSearchView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                NavigationLink(destination: PlatformSelectView()) {
                    HStack {
                        Image(systemName: "rectangle.stack.fill.badge.play")
                            .font(.system(size: 25))
                        Text("プラットフォームから探す")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .navigationTitle("ソフトを探す")
        }
    }
}

// MARK: - TabView全体構成
struct Nintendo_ch: View {
    var body: some View {
        TabView {
            Nintendoch_VideoView()
                .tabItem {
                    Label("ムービー", systemImage: "play.rectangle.fill")
                }
            
            SoftwareSearchView()
                .tabItem {
                    Label("ソフトを探す", systemImage: "magnifyingglass")
                }
        }
    }
}

// MARK: - プレビュー
struct Nintendo_ch_Previews: PreviewProvider {
    static var previews: some View {
        Nintendo_ch()
    }
}
