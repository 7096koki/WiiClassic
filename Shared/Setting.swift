import SwiftUI

// MARK: - 設定画面
// バージョン履歴や著作権情報を表示する画面
struct SettingsView: View {
    var body: some View {
        List {
            Section(header: Text("アプリ情報")) {
                // バージョン履歴画面へのリンクを復活させました
                NavigationLink(destination: VersionHistoryView()) {
                    Text("バージョン履歴")
                }
                // 著作権について画面へのリンク
                NavigationLink(destination: CopyrightView()) {
                    Text("著作権について")
                }
            }
        }
        .navigationTitle("設定")
    }
}

// MARK: - バージョン履歴画面
struct VersionHistoryView: View {
    var body: some View {
        List {
            Text("Ver 1.0.0-α1 (2025/08/14)\n")
            
        }
        .navigationTitle("バージョン履歴")
    }
}

// MARK: - 著作権画面
struct CopyrightView: View {
    var body: some View {
        Text("© 2025 WiiClassic App\n\nこのアプリはWiiメニューを参考に作成されています。\n著作権は各権利者に帰属します。")
            .padding()
            .navigationTitle("著作権について")
    }
}
