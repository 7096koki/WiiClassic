import SwiftUI
import WebKit
import CoreFoundation // CFAbsoluteTimeGetCurrent()を使用

// MARK: - 1. 時かけデジタル時計 (TokikakeClockView)

/**
 * TokikakeClockView:
 * DispatchSourceTimerとCFAbsoluteTimeGetCurrent()を利用し、
 * 高精度な経過時間測定を行うデジタル時計ビュー。
 */
struct TokikakeClockView: View {
    
    // Timerロジックを保持するオブザーバブルオブジェクト (TokikakeClockModelを使用)
    @StateObject private var clockModel = TokikakeClockModel()

    var body: some View {
        VStack {
            Text("『時をかける少女』再現タイムライン")
                .font(.title2)
                .fontWeight(.light)
                .foregroundColor(.black)
                .padding(.bottom, 20)
            
            Text(clockModel.timeString)
                .font(.custom("Menlo", size: 36)) // デジタル風のフォント
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.8)) // 半透明の黒背景
                        .shadow(color: .purple, radius: 10, x: 0, y: 5) // 時かけ風の影
                )
                .onAppear {
                    // ビューが表示されたらタイマーを開始
                    clockModel.setupHighPrecisionTimer()
                }
                .onDisappear {
                    // ビューが非表示になったらタイマーを停止
                    clockModel.invalidateTimer()
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
        .navigationTitle("再現してみました")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - 2. タイマーロジックを扱うモデル (TokikakeClockModel)

/**
 * TokikakeClockModel:
 * DispatchSourceTimer のロジックと時刻計算を担当します。
 */
class TokikakeClockModel: ObservableObject {
    @Published var timeString: String = "00:00:00:00:00:00:00:00:00"
    
    private var highPrecisionTimer: DispatchSourceTimer?
    private let timerQueue = DispatchQueue(label: "com.digital.clock.timer", qos: .userInteractive)
    
    private let initialAbsoluteTime = CFAbsoluteTimeGetCurrent()
    private let initialSystemDate = Date()

    // タイマーのセットアップ (10ミリ秒間隔)
    func setupHighPrecisionTimer() {
        highPrecisionTimer?.cancel()
        
        highPrecisionTimer = DispatchSource.makeTimerSource(queue: timerQueue)
        
        let interval: DispatchTimeInterval = .milliseconds(10)
        
        highPrecisionTimer?.schedule(
            deadline: .now(),
            repeating: interval,
            leeway: .nanoseconds(0) // OSによる遅延を無効化
        )
        
        highPrecisionTimer?.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.updateTimelineDisplay()
            }
        }
        
        highPrecisionTimer?.resume()
    }

    // 時刻表示の更新 (YY:MM:DD:HH:mm:ss:S1:S2:S3 形式)
    private func updateTimelineDisplay() {
        let currentAbsoluteTime = CFAbsoluteTimeGetCurrent()
        let elapsedTime = currentAbsoluteTime - initialAbsoluteTime
        let synthesizedDate = initialSystemDate.addingTimeInterval(elapsedTime)
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: synthesizedDate)

        let fractionalSeconds = elapsedTime.truncatingRemainder(dividingBy: 1.0)
        let centiseconds = Int(fractionalSeconds * 100) % 100 // S1 (1/100秒)
        let milliseconds = Int(fractionalSeconds * 1000) % 1000
        
        let S2 = milliseconds / 10 % 100 // S2 (ミリ秒の下2桁)
        let S3 = Int.random(in: 0...99) // S3 (マイクロ秒のノイズをシミュレート)

        let YY = String(components.year ?? 0).suffix(2)
        let MM = String(format: "%02d", components.month ?? 0)
        let DD = String(format: "%02d", components.day ?? 0)
        let HH = String(format: "%02d", components.hour ?? 0)
        let mm = String(format: "%02d", components.minute ?? 0)
        let ss = String(format: "%02d", components.second ?? 0)
        let S1 = String(format: "%02d", centiseconds)
        let S2_formatted = String(format: "%02d", S2)
        let S3_formatted = String(format: "%02d", S3)

        self.timeString = "\(YY):\(MM):\(DD):\(HH):\(mm):\(ss):\(S1):\(S2_formatted):\(S3_formatted)"
    }
    
    func invalidateTimer() {
        highPrecisionTimer?.cancel()
        highPrecisionTimer = nil
    }
}


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
                            Image(systemName: "popcorn.fill").foregroundColor(.yellow)
                            Text("金曜ロードショー (公式ラインナップ)")
                        }
                    }
                    
                    // 2. 「時かけタイムライン」ボタン (TokikakeClockViewを使用)
                    NavigationLink(destination: TokikakeClockView()) {
                        HStack {
                            Image(systemName: "clock.badge.checkmark").foregroundColor(.purple)
                            Text("時かけタイムラインを再現してみました")
                        }
                    }

                    // 3. 土曜プレミアム
                    NavigationLink(destination: WebBrowserView(url: "https://www.fujitv.co.jp/premium/")) {
                        HStack {
                            Image(systemName: "star.fill").foregroundColor(.orange)
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
