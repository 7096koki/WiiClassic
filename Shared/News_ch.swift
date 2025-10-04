// News_ch.swift

import SwiftUI

// MARK: - メインビュー
struct News_ch: View {
    @State private var newsItems: [RSSItem] = []
    
    var body: some View {
        VStack {
            Text("ニュースチャンネル")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 50)
            
            // チャンネル選択ボタン
            VStack(spacing: 10) {
                // 任天堂ボタン
                Button(action: {
                    self.fetchRSSFeed(url: "https://www.nintendo.co.jp/news/whatsnew.xml")
                }) {
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                        Text("ニンテンドー")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                }
                
                // Yahoo!ニュースボタン
                Button(action: {
                    self.fetchRSSFeed(url: "https://news.yahoo.co.jp/rss/topics/top-picks.xml")
                }) {
                    HStack {
                        Image(systemName: "newspaper.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                        Text("主要")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                }
                
                // URL入力ボタン
                NavigationLink(destination: URLInputView(newsItems: $newsItems)) {
                    HStack {
                        Image(systemName: "link.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding(.leading, 20)
                        Text("URLを入力")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 15)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            if newsItems.isEmpty {
                Spacer()
                ProgressView("ニュースを取得中...")
                    .foregroundColor(.white)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                Spacer()
            } else {
                List(newsItems, id: \.link) { item in
                    NavigationLink(destination: WebBrowserView(url: item.link)) {
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(item.pubDate)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // 著作権表示
            VStack {
                Text("提供")
                Text("任天堂-Nintendo")
                Text("Yahoo!ニュース")
            }
            .font(.caption)
            .foregroundColor(.white)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .navigationTitle("ニュースチャンネル")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // RSSフィードを取得して解析する
    private func fetchRSSFeed(url urlString: String) {
        // 新しいニュースを取得する前に既存のアイテムをクリア
        self.newsItems = []
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching RSS feed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let parser = XMLParser(data: data)
            let delegate = RSSParserDelegate()
            parser.delegate = delegate
            
            if parser.parse() {
                DispatchQueue.main.async {
                    self.newsItems = delegate.parsedItems
                }
            }
        }
        task.resume()
    }
}

// URL入力画面
struct URLInputView: View {
    @State private var urlString: String = ""
    @Binding var newsItems: [RSSItem]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("RSS URLを入力")
                .font(.headline)
                .padding(.top)
            
            TextField("https://example.com/feed.xml", text: $urlString)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.URL)
                .autocapitalization(.none)
            
            Button("取得") {
                // XMLParserでURLを取得する
                guard let url = URL(string: urlString) else { return }
                
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    
                    let parser = XMLParser(data: data)
                    let delegate = RSSParserDelegate()
                    parser.delegate = delegate
                    
                    if parser.parse() {
                        DispatchQueue.main.async {
                            self.newsItems = delegate.parsedItems
                        }
                    }
                }
                task.resume()
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("URL入力")
    }
}
