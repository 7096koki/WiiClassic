import SwiftUI
import Foundation // XMLParserを使用するために必要
import WebKit

// MARK: - モデル
// RSSアイテムのモデルはここに一つだけ定義します
struct RSSItem: Identifiable {
    let id = UUID()
    let title: String
    let link: String
    let pubDate: String
}

// XMLParserDelegate
class RSSParserDelegate: NSObject, XMLParserDelegate {
    var parsedItems: [RSSItem] = []
    var currentElement = ""
    var currentTitle = ""
    var currentLink = ""
    var currentPubDate = ""
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "item" {
            currentTitle = ""
            currentLink = ""
            currentPubDate = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !data.isEmpty {
            switch currentElement {
            case "title":
                currentTitle += data
            case "link":
                currentLink += data
            case "pubDate":
                currentPubDate += data
            default:
                break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            let newsItem = RSSItem(title: currentTitle, link: currentLink, pubDate: currentPubDate)
            parsedItems.append(newsItem)
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

// MARK: - 0. SwiftUI Color Extension
// Hexコード文字列からColorを作成できるようにする拡張機能
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        // 【エラー修正箇所は前回修正済み】
        // モダンなSwiftでサポートされている`scanHexInt64`を使用
        guard Scanner(string: hex).scanHexInt64(&int) else {
            self.init(.sRGB, red: 0, green: 0, blue: 0, opacity: 1)
            return
        }
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 1, 1, 1) // 不正な長さの場合は白として扱う
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
