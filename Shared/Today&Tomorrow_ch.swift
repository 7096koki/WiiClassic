import SwiftUI

// MARK: - 1. モデル: おみくじの結果とランキング定義

/**
 * OmikujiResult: おみくじの結果とその表示スタイルを定義する構造体
 * rankプロパティを追加し、運勢の強さ（1が最高）を明確にしました。
 */
struct OmikujiResult: Identifiable, Comparable {
    let id = UUID()
    let name: String // 例: 大々大吉, 凶
    let description: String // 運勢の説明
    let color: Color // 結果に応じたテーマカラー
    let iconName: String // SF Symbolsのアイコン名
    let rank: Int // 運勢の順位 (1が最高運勢)
    
    // Comparableプロトコル実装: ランキング順にソートできるようにする
    static func < (lhs: OmikujiResult, rhs: OmikujiResult) -> Bool {
        return lhs.rank < rhs.rank
    }
    
    // 初期表示用のおみくじ結果。デフォルトの色を .gray に変更し、運勢色との重複を避ける
    static let defaultResult = OmikujiResult(
        name: "運勢",
        description: "下のボタンを押して、今日のおみくじを引いてみましょう！",
        color: .gray, // 互換性のある標準色
        iconName: "questionmark.circle.fill",
        rank: 99
    )
}

// MARK: - 2. サブビュー: おみくじ結果のカード表示

/**
 * FortuneCardView:
 * OmikujiResultのデータを受け取り、結果を視覚的に表示するカードコンポーネント
 */
struct FortuneCardView: View {
    let fortune: OmikujiResult
    
    var body: some View {
        VStack(spacing: 20) {
            
            // アイコンと結果名
            HStack {
                Image(systemName: fortune.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(fortune.color)
                
                Text(fortune.name)
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundColor(.black)
            }
            .padding(.bottom, 10)
            
            // 説明文
            Text(fortune.description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                // 【修正点】テキストがカード内で最大幅を使い、かつ行数制限なしで表示されるように修正
                .frame(maxWidth: .infinity)
                .lineLimit(nil)
            
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: fortune.color.opacity(0.3), radius: 15, x: 0, y: 10)
        )
        // カードの幅を親ビューの幅の約80%に制限し、見やすさを確保
        .frame(maxWidth: 400)
        .transition(.scale.animation(.spring(response: 0.4, dampingFraction: 0.6)))
    }
}

// MARK: - 3. サブビュー: 運勢指数表

/**
 * FortuneRankIndexView:
 * 全てのおみくじ結果のランキングをリスト表示するコンポーネント
 */
struct FortuneRankIndexView: View {
    let allFortunes: [OmikujiResult] // 運勢の全リスト
    
    var sortedFortunes: [OmikujiResult] {
        // rankプロパティでソート（1位から順番）
        allFortunes.sorted()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("運勢指数表 (ランキング)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(sortedFortunes.filter { $0.rank < 99 }) { fortune in
                    HStack {
                        // 順位表示
                        Text("\(fortune.rank)位")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 40, alignment: .leading)
                            .foregroundColor(.gray)
                        
                        // 運勢名とアイコン
                        HStack(spacing: 5) {
                            Image(systemName: fortune.iconName)
                                .foregroundColor(fortune.color)
                                .font(.caption)
                            Text(fortune.name)
                                .font(.subheadline)
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }
}


// MARK: - 4. メインチャンネルビュー: 今日と明日の占いラッキーチャンネル

/**
 * DailyFortuneChannelView:
 * チャンネルのメインビュー。おみくじロジックとUIをカプセル化しています。
 */
struct TodayandTomorrow_ch: View {
    
    // 現在のおみくじの結果を保持するState
    @State private var currentFortune: OmikujiResult = .defaultResult
    
    // おみくじの結果の定義（乱数で選択される候補）
    private let fortunes: [OmikujiResult] = [
        // 超ラッキー
        // ※ ユーザーの要望により、説明文は長いまま維持しています。
        OmikujiResult(name: "大々大吉", description: "宇宙規模の幸運！何をやっても成功します。予想外のプレゼントや、長年の夢が叶うかもしれません。積極的に行動しましょう。", color: .pink, iconName: "sparkles", rank: 1),
        OmikujiResult(name: "大大吉", description: "奇跡が起きるかも。大胆な行動が吉と出ます。特に人間関係で大きな進展が期待できます。", color: .red, iconName: "heart.fill", rank: 2),
        
        // 良い運勢
        OmikujiResult(name: "大吉", description: "最高にラッキーな日です！新しい挑戦を始めてみましょう。金運、仕事運ともに絶好調の一日です。", color: .orange, iconName: "crown.fill", rank: 3),
        OmikujiResult(name: "中吉", description: "良い運勢です。計画通りに進めれば成功します。特に午後の集中力が高いでしょう。", color: .yellow, iconName: "star.fill", rank: 4),
        OmikujiResult(name: "小吉", description: "そこそこの運勢です。慎重に行動しましょう。大きな決断は避けて、現状維持に努めるのが吉です。", color: .green, iconName: "hand.thumbsup.fill", rank: 5),
        
        // 平均的な運勢
        OmikujiResult(name: "吉", description: "平均的な運勢です。焦らず、地道に過ごしましょう。特に家族との時間を大切にすると運気が上がります。", color: .blue, iconName: "leaf.fill", rank: 6),
        OmikujiResult(name: "末吉", description: "これから良くなります。夕方以降に期待！今は準備期間として力を蓄えましょう。", color: .purple, iconName: "arrow.up.circle.fill", rank: 7),
        
        // 悪い運勢
        OmikujiResult(name: "小凶", description: "少し注意が必要な日。言動に気をつけましょう。特に誤解が生じやすいので、報告・連絡・相談を徹底しましょう。", color: .red.opacity(0.7), iconName: "exclamationmark.triangle.fill", rank: 8),
        OmikujiResult(name: "凶", description: "今日は静かに過ごしましょう。明日に期待です。無理せず、早めに休息を取ることをおすすめします。", color: .gray, iconName: "bolt.slash.fill", rank: 9),
        OmikujiResult(name: "大凶", description: "最大級の不運。全ての行動を最小限に抑えてください。特に貴重品の紛失に注意し、安全第一で過ごしましょう。今日は新しいことを始めないでください。", color: .black, iconName: "m", rank: 10)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 30) {
                        
                        Text("今日と明日の占いラッキーチャンネル")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                        
                        // おみくじ結果表示カード
                        FortuneCardView(fortune: currentFortune)
                        
                        // おみくじを引くボタン
                        Button(action: drawNewFortune) {
                            Text("おみくじを引く")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 40)
                                .background(currentFortune.color.opacity(0.8))
                                .clipShape(Capsule())
                                .shadow(color: currentFortune.color.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        
                        // 運勢指数表を追加
                        FortuneRankIndexView(allFortunes: fortunes)
                        
                        Spacer()
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("今日の運勢")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    /**
     * drawNewFortune:
     * fortunes配列からランダムに結果を選択し、Stateを更新します。
     * 前回と同じ結果が連続しないようにフィルタリングしています。
     */
    func drawNewFortune() {
        // 現在の結果以外からランダムに選択するロジック
        let availableFortunes = fortunes.filter { $0.id != currentFortune.id }
        if let newFortune = availableFortunes.randomElement() {
            withAnimation(.spring()) {
                currentFortune = newFortune
            }
        } else if let newFortune = fortunes.randomElement() {
             // フィルタリングの結果要素が一つも残らない場合、全体からランダムに選択
            withAnimation(.spring()) {
                currentFortune = newFortune
            }
        }
    }
}
