import SwiftUI
import WebKit // WKWebViewを使用するために必要
import Foundation // URLSessionを使用するために必要

#if os(macOS)
import AppKit // macOS向けのWebViewで使用
#endif

// MARK: - テレビの友チャンネル画面
// bangumi.orgのサイトや映画情報を表示する画面
struct TVFriendChannelView: View {
    var body: some View {
        VStack {
            
            Spacer()
            
            // メニューボタンの配置
            HStack(spacing: 50) {
                // 番組表サイト表示ボタン
                NavigationLink(destination: EPGView()) {
                    VStack {
                        Image(systemName: "calendar")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                        Text("番組表")
                    }
                }
                
                // 番組情報表示ボタン
                NavigationLink(destination: ProgramInfoView()) {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                        Text("番組を探す")
                    }
                }
            }
            .padding(.bottom, 50)
        }
        .navigationTitle("テレビの友チャンネル")
    }
}

// MARK: - WebView
// アプリ内でウェブサイトを表示するためのView
// iOSとmacOSで異なるRepresentableを使用します
#if os(iOS)
struct WebView: UIViewRepresentable {
    let url: URL

    // コンテキストを使用してUIViewを作成します
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    // 変更が発生したときにUIViewを更新します
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
#elseif os(macOS)
struct WebView: NSViewRepresentable {
    let url: URL

    // コンテキストを使用してNSViewを作成します
    func makeNSView(context: Context) -> WKWebView {
        return WKWebView()
    }

    // 変更が発生したときにNSViewを更新します
    func updateNSView(_ nsView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        nsView.load(request)
    }
}
#endif

// MARK: - 番組表サイト画面
// 現在の日付でURLを自動生成し、WebViewで表示する
struct EPGView: View {
    var body: some View {
        
        // URL文字列をURL型に変換
        if let url = URL(string: "https://bangumi.org/epg/td?ggm_group_id=64") {
            WebView(url: url)
                .navigationTitle("番組表")
        } else {
            // URLが不正な場合のフォールバック
            Text("URLが無効です。")
                .navigationTitle("番組表")
        }
    }
}

// MARK: - 番組情報画面
// 金曜ロードショーと土曜プレミアムのWebサイトを表示する
struct ProgramInfoView: View {
    // WebサイトのURL
    let kinroURL = URL(string: "https://kinro.ntv.co.jp/lineup")!
    let doyoURL = URL(string: "https://www.fujitv.co.jp/premium/")!

    var body: some View {
        List {
            Section(header: Text("番組情報")) {
                // 金曜ロードショーのサイトへ遷移するリンク
                NavigationLink(destination: WebView(url: kinroURL)) {
                    VStack(alignment: .leading) {
                        Text("金曜ロードショー")
                            .font(.headline)
                        Text("公式Webサイト")
                            .font(.subheadline)
                    }
                }
                // 土曜プレミアムのサイトへ遷移するリンク
                NavigationLink(destination: WebView(url: doyoURL)) {
                    VStack(alignment: .leading) {
                        Text("土曜プレミアム")
                            .font(.headline)
                        Text("公式Webサイト")
                            .font(.subheadline)
                    }
                }
            }
        }
        .navigationTitle("番組を探す")
    }
}
