// TVnotomo_ch.swift

import SwiftUI
import WebKit

// MARK: - メインビュー
struct TVnotomo_ch: View {
    var body: some View {
        VStack(spacing: 0) {
            // 番組表を画面の中央に埋め込み
            WebBrowserView(url: "https://bangumi.org/epg/td?ggm_group_id=64")
            
            // 下部メニューバー
            HStack(spacing: 40) {
                Spacer()
                
                // 番組を探すボタン
                NavigationLink(destination: PresetSearchView()) {
                    ChannelButton(name: "番組を探す", imageName: "magnifyingglass")
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("テレビの友チャンネル")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - メニューバー用ボタン
struct ChannelButton: View {
    let name: String
    let imageName: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: imageName)
                .font(.system(size: 24))
                .foregroundColor(.gray)
            Text(name)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - 番組を探すビュー
struct PresetSearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // プリセットから探す (リスト形式に修正)
            VStack(alignment: .leading, spacing: 10) {
                Text("プリセットから探す")
                    .font(.headline)
                    .foregroundColor(.black)
                
                List {
                    NavigationLink(destination: WebBrowserView(url: "https://kinro.ntv.co.jp/lineup")) {
                        Text("金曜ロードショー")
                    }
                    
                    NavigationLink(destination: WebBrowserView(url: "https://www.fujitv.co.jp/premium/")) {
                        Text("土曜プレミアム")
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.3))
            .cornerRadius(10)
            
            // キーワードで探す
            VStack(alignment: .leading, spacing: 10) {
                Text("キーワードで探す")
                    .font(.headline)
                    .foregroundColor(.black)
                
                HStack {
                    TextField("キーワードを入力", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // 検索ボタン
                    NavigationLink(destination: WebBrowserView(url: "https://bangumi.org/search?q=\(searchText)&area_code=39")) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(5)
                    }
                }
            }
            .padding()
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("番組を探す")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SearchButton: View {
    let name: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(name)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(color)
                .cornerRadius(10)
        }
    }
}

// MARK: - Webブラウザビュー
struct WebBrowserView: View {
    let url: String
    
    var body: some View {
        ZStack {
            WebView(url: url)
        }
        .navigationTitle("ブラウザ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// WKWebViewをSwiftUIでラップ
struct WebView: UIViewRepresentable {
    let url: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
}
