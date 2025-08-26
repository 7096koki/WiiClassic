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
