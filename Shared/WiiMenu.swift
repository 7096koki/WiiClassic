import SwiftUI

// MARK: - メインビュー
// アプリのエントリーポイントとなるビューです
struct WiiMenu: View {
    var body: some View {
        // ナビゲーションを管理するためのNavigationView
        NavigationView {
            MainMenuView()
        }
    }
}

// MARK: - Wii風チャンネルボタン
// チャンネルの見た目を定義する再利用可能なコンポーネント
struct WiiChannelButton: View {
    let title: String
    let iconName: String
    let iconColor: Color
    let backgroundColor: Color
    
    var body: some View {
        VStack {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(iconColor)
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: 120, height: 100) // チャンネルのサイズ
        .background(backgroundColor)
        .cornerRadius(20) // 角を丸くする
        .shadow(radius: 5) // 立体感を出すための影
    }
}

// MARK: - メインメニュー画面
// Wii風のチャンネルが並ぶメイン画面
struct MainMenuView: View {
    var body: some View {
        VStack(spacing: 40) {
            Text("メニュー")
                .font(.largeTitle)
                .bold()
            
            // チャンネルの配置
            NavigationLink(destination: TVFriendChannelView()) {
                WiiChannelButton(
                    title: "テレビの友",
                    iconName: "tv.fill",
                    iconColor: .white,
                    backgroundColor: .blue // テレビの友チャンネルは青色
                )
            }
            
            // 設定画面へのリンク
            // Spacerで画面下部に配置
            Spacer()
            NavigationLink(destination: SettingsView()) {
                WiiChannelButton(
                    title: "設定",
                    iconName: "gearshape.fill",
                    iconColor: .gray,
                    backgroundColor: Color(white: 0.9)
                )
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("Wiiメニュー")
        .navigationBarHidden(true) // ナビゲーションバーを非表示にして、Wii風に
    }
}
