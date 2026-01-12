import SwiftUI

// MARK: - モデル定義
// 他のファイルと名前がぶつからないよう、念のため構造体名をユニークにしています
struct LuckyFortuneModel: Identifiable, Comparable {
    let id = UUID()
    let name: String
    let description: String
    let color: Color
    let iconName: String
    let rank: Int
    
    static func < (lhs: LuckyFortuneModel, rhs: LuckyFortuneModel) -> Bool {
        return lhs.rank < rhs.rank
    }
    
    static let defaultResult = LuckyFortuneModel(
        name: "運勢",
        description: "下のボタンを押して、今日のおみくじを引いてみましょう！",
        color: .gray,
        iconName: "questionmark.circle.fill",
        rank: 99
    )
}

// MARK: - メインビュー
struct TodayandTomorrow_ch: View {
    @State private var currentFortune: LuckyFortuneModel = .defaultResult
    @State private var isSpinning = false
    @State private var countdown = 0
    @State private var tempIcon = "questionmark.circle.fill"
    
    // おみくじの結果定義
    private let fortunes: [LuckyFortuneModel] = [
        LuckyFortuneModel(name: "大々大吉", description: "宇宙規模の幸運！何をやっても成功します。予想外のプレゼントや、長年の夢が叶うかもしれません。", color: .pink, iconName: "sparkles", rank: 1),
        LuckyFortuneModel(name: "大大吉", description: "奇跡が起きるかも。大胆な行動が吉と出ます。特に人間関係で大きな進展が期待できます。", color: .red, iconName: "heart.fill", rank: 2),
        LuckyFortuneModel(name: "大吉", description: "最高にラッキーな日です！新しい挑戦を始めてみましょう。金運、仕事運ともに絶好調の一日です。", color: .orange, iconName: "crown.fill", rank: 3),
        LuckyFortuneModel(name: "中吉", description: "良い運勢です。計画通りに進めれば成功します。特に午後の集中力が高いでしょう。", color: .yellow, iconName: "star.fill", rank: 4),
        LuckyFortuneModel(name: "小吉", description: "そこそこの運勢です。慎重に行動しましょう。大きな決断は避けて現状維持が吉です。", color: .green, iconName: "hand.thumbsup.fill", rank: 5),
        LuckyFortuneModel(name: "吉", description: "平均的な運勢です。焦らず、地道に過ごしましょう。家族との時間を大切にすると運気が上がります。", color: .blue, iconName: "leaf.fill", rank: 6),
        LuckyFortuneModel(name: "末吉", description: "これから良くなります。夕方以降に期待！今は準備期間として力を蓄えましょう。", color: .purple, iconName: "arrow.up.circle.fill", rank: 7),
        LuckyFortuneModel(name: "小凶", description: "少し注意が必要な日。言動に気をつけましょう。報告・連絡・相談を徹底しましょう。", color: .red.opacity(0.7), iconName: "exclamationmark.triangle.fill", rank: 8),
        LuckyFortuneModel(name: "凶", description: "今日は静かに過ごしましょう。明日に期待です。無理せず、早めに休息を取ることをおすすめします。", color: .gray, iconName: "bolt.slash.fill", rank: 9),
        LuckyFortuneModel(name: "大凶", description: "最大級の不運。全ての行動を最小限に抑えてください。安全第一で過ごしましょう。", color: .black, iconName: "exclamationmark.octagon.fill", rank: 10)
    ]
    
    var body: some View {
        ZStack {
            // 背景色
            Color(white: 0.95).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    Text("今日と明日の占い\nラッキーチャンネル")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.top, 40)
                    
                    // 演出エリア
                    ZStack {
                        if isSpinning {
                            VStack(spacing: 20) {
                                Image(systemName: tempIcon)
                                    .font(.system(size: 80))
                                    .foregroundColor(.blue)
                                    // 回転アニメーション
                                    .rotationEffect(.degrees(isSpinning ? 360 : 0))
                                    .animation(Animation.linear(duration: 0.15).repeatForever(autoreverses: false), value: isSpinning)
                                
                                Text("\(countdown)")
                                    .font(.system(size: 50, weight: .black, design: .monospaced))
                                    .foregroundColor(.blue)
                            }
                            .transition(.opacity)
                        } else {
                            ResultDisplayCard(fortune: currentFortune)
                                .transition(.asymmetric(insertion: .scale, removal: .opacity))
                        }
                    }
                    .frame(height: 300)
                    .padding(.horizontal)
                    
                    // 抽選ボタン
                    Button(action: startSequence) {
                        Text(isSpinning ? "鑑定中..." : "うらなう")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 55)
                            .background(isSpinning ? Color.gray : Color.blue)
                            .cornerRadius(27.5)
                            .shadow(radius: isSpinning ? 0 : 4)
                    }
                    .disabled(isSpinning)
                    
                    // 指数表
                    VStack(alignment: .leading, spacing: 10) {
                        Text("運勢ランキング")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(fortunes.sorted().filter({ $0.rank < 99 })) { item in
                                    VStack {
                                        Text("\(item.rank)位").font(.caption2).foregroundColor(.gray)
                                        Image(systemName: item.iconName).foregroundColor(item.color)
                                        Text(item.name).font(.system(size: 10, weight: .bold))
                                    }
                                    .frame(width: 55, height: 70)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .opacity(isSpinning ? 0.3 : 1)
                    
                    Spacer(minLength: 40)
                }
            }
        }
    }
    
    // 抽選開始
    func startSequence() {
        isSpinning = true
        countdown = 3
        
        // アイコン高速切り替え
        let iconTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            tempIcon = fortunes.randomElement()?.iconName ?? "questionmark"
        }
        
        // カウントダウン
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                iconTimer.invalidate()
                
                withAnimation(.spring()) {
                    currentFortune = fortunes.randomElement() ?? .defaultResult
                    isSpinning = false
                }
            }
        }
    }
}

// MARK: - 結果表示用カード（別構造体にしてエラー回避）
struct ResultDisplayCard: View {
    let fortune: LuckyFortuneModel
    
    var body: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                Image(systemName: fortune.iconName)
                    .font(.system(size: 50))
                    .foregroundColor(fortune.color)
                
                Text(fortune.name)
                    .font(.system(size: 40, weight: .black, design: .rounded))
            }
            
            Text(fortune.description)
                .font(.callout)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - プレビュー
struct TodayandTomorrow_ch_Previews: PreviewProvider {
    static var previews: some View {
        TodayandTomorrow_ch()
    }
}
