// NintendoChannelView.swift

import SwiftUI
import WebKit

// MARK: - モデル
// 動画データを管理するモデル
struct Video: Identifiable {
    let id = UUID()
    let title: String
    let youtubeURL: String
}

// MARK: - 動画再生ビュー
// 動画を全画面で再生するためのビュー
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

// MARK: - メインビュー
// みんなのニンテンドーチャンネルのメイン画面
struct Nintendo_ch: View {
    // Wiiウェアの静的データ
    private let videos: [Video] = [
        Video(title: "Nintendo Switch 紹介映像", youtubeURL: "https://www.youtube.com/embed/Jj4sfry-wYw?gl=JP"),
        Video(title: "Nintendo Switch 2 紹介映像", youtubeURL: "https://www.youtube.com/embed/oCc6N_EoT44?gl=JP"),
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "gamecontroller.fill") // アイコンを追加
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .padding(.leading)
                    
                    Text("みんなのニンテンドーチャンネル")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.top, 50)
                
                
                // 動画リスト
                List {
                    ForEach(videos) { video in
                        NavigationLink(destination: VideoPlayerView(video: video)) {
                            Text(video.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .listStyle(PlainListStyle()) // Xcode 12.5.1互換
            }
        }
    }
}

