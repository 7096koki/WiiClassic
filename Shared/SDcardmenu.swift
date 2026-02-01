import SwiftUI

// MARK: - SDカードメニュー View
struct SDCardMenuView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // ページ管理用の状態
    @State private var currentPage: Int = 0
    
    // WiiのSDカードメニューは最大20ページ
    let totalPages = 20
    let channelsPerPage = 10

    // MARK: - チャンネルデータの定義（お気持ち程度のサンプル）
    var channels: [(String, String, Color)] {
        [
            
        ]
    }
    
    // Wiiメニューと全く同じカラム設定（配置がズレないように固定）
    var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 4 : 2
        return Array(repeating: .init(.flexible()), count: count)
    }
    
    // MARK: - 20ページ分のグリッドデータを生成
    var pages: [[(String, String, Color)]] {
        var result: [[(String, String, Color)]] = []
        let totalCount = channels.count
        
        for p in 0..<totalPages {
            let start = p * channelsPerPage
            let end = start + channelsPerPage
            
            var page: [(String, String, Color)] = []
            if start < totalCount {
                let actualEnd = min(end, totalCount)
                page = Array(channels[start..<actualEnd])
            }
            
            // 空のスロット（配置維持用）
            let dummy = ("DUMMY", "", Color.white.opacity(0.15))
            page.append(contentsOf: Array(repeating: dummy, count: max(0, channelsPerPage - page.count)))
            result.append(page)
        }
        return result
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                // 背景：SDカードメニュー特有の濃いグレー
                Color(red: 0.12, green: 0.12, blue: 0.12).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // チャンネル表示エリア（Wiiメニューと同一スタック）
                    TabView(selection: $currentPage) {
                        ForEach(pages.indices, id: \.self) { pageIndex in
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(pages[pageIndex].indices, id: \.self) { i in
                                    let channel = pages[pageIndex][i]
                                    if channel.0 == "DUMMY" {
                                        ChannelIcon(name: "", imageName: "", color: channel.2)
                                    } else {
                                        NavigationLink(destination: Text("\(channel.0) 起動中...")) {
                                            ChannelIcon(name: channel.0, imageName: channel.1, color: channel.2)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .padding()
                            .tag(pageIndex)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // 下部エリアの高さをWiiメニューと一致させる
                    Spacer().frame(height: 180)
                }
                
                // 下部グレーゾーン（時計の代わりにページ表記）
                ZStack(alignment: .top) {
                    // 背景
                    Color.black.opacity(0.4)
                        .frame(height: 180)
                        .ignoresSafeArea(edges: .bottom)
                    
                    // 上部の青い境界線
                    Rectangle()
                        .fill(Color(red: 0.0, green: 0.4, blue: 0.9))
                        .frame(height: 4)
                    
                    // 中央のページ表記（時計と同じ位置・サイズ感）
                    VStack {
                        Spacer()
                        
                        // 1/20 などの表記を時計と同じフォント感で表示
                        VStack(spacing: 4) {
                            Text("0\(currentPage + 1) / \(totalPages)")
                                .font(.system(size: 48, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 2, x: 2, y: 2)
                            
                            // 補助テキスト（Wiiリモコンの操作ガイド的な位置）
                            Text("SD CARD MENU")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white.opacity(0.4))
                                .kerning(2)
                        }
                        
                        Spacer()
                    }
                }
                .frame(height: 180)
            }
            .navigationBarHidden(true)
        }
    }
}
