import SwiftUI
import WebKit
import CoreFoundation // CFAbsoluteTimeGetCurrent()を使用

// MARK: - 3. メインビュー

struct TVnotomo_ch: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 番組表を画面の中央に埋め込み
                WebBrowserView(url: "https://bangumi.org/epg/td?ggm_group_id=64")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 下部メニューバー
                HStack(spacing: 40) {
                    Spacer()
                    
                    // 番組コラムボタン
                    NavigationLink(destination: PresetSearchView()) {
                        ChannelButton(name: "番組コラム", imageName: "square.stack.fill")
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .shadow(radius: 5)
            }
            .navigationTitle("テレビの友チャンネル")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 4. 番組コラムビュー (リストスタイルを整理)

struct PresetSearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 20) {
            
            // キーワードで探す部分
            VStack(alignment: .leading, spacing: 10) {
                Text("キーワードで番組を探す")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                HStack {
                    TextField("キーワードを入力", text: $searchText)
                    
                    // 検索ボタン
                    NavigationLink(
                        destination: WebBrowserView(
                            url: "https://bangumi.org/search?q=\(searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&area_code=39"
                        )
                    ) {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray5).opacity(0.5))
            .cornerRadius(10)
            
            // プリセットから探す
            VStack(alignment: .leading, spacing: 10) {
                Text("プリセットから探す")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                List {
                    // 1. 金曜ロードショー (公式ラインナップ)
                    NavigationLink(destination: WebBrowserView(url: "https://kinro.ntv.co.jp/lineup")) {
                        HStack {
                            Text("金曜ロードショー (公式ラインナップ)")
                        }
                    }

                    // 3. 土曜プレミアム
                    NavigationLink(destination: WebBrowserView(url: "https://www.fujitv.co.jp/premium/")) {
                        HStack {
                            Text("土曜プレミアム")
                        }
                    }
                }
                .frame(height: 200) // リストの高さを調整
                // .cornerRadius(10) // insetGroupedスタイルでは不要なため削除
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
        .navigationTitle("番組コラム")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 5. その他のサポートビュー

// メニューバー用ボタン
struct ChannelButton: View {
    let name: String
    let imageName: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: imageName)
                .font(.system(size: 24))
                .foregroundColor(.blue)
            Text(name)
                .font(.caption)
                .foregroundColor(.blue)
        }
    }
}
