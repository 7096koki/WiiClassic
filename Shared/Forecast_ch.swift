import SwiftUI

// MARK: - 1. データ構造の定義
// ユーザーが選択できる地域と、APIで使用するコードを紐づける
struct City: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let code: String // APIで使う地域コード
}

// 主要な地域コードのリスト
struct CityManager {
    /// 全国の主要な予報区を代表する17都市
    static let cities: [City] = [
        // 北海道・東北
        City(name: "札幌", code: "016000"), // 北海道
        City(name: "仙台", code: "040000"), // 宮城県
        
        // 関東・甲信
        City(name: "東京", code: "130000"), // 東京都
        City(name: "新潟", code: "150000"), // 新潟県
        
        // 東海・北陸
        City(name: "静岡", code: "220000"), // 静岡県
        City(name: "名古屋", code: "230000"), // 愛知県
        City(name: "金沢", code: "170000"), // 石川県
        
        // 近畿
        City(name: "大阪", code: "270000"), // 大阪府
        
        // 中国・四国
        City(name: "広島", code: "340000"), // 広島県
        City(name: "高知", code: "390000"), // 高知県
        
        // 九州・沖縄
        City(name: "福岡", code: "400000"), // 福岡県
        City(name: "鹿児島", code: "460100"), // 鹿児島県
        City(name: "那覇", code: "471000"), // 沖縄県
        
    ]
    static let defaultCity = cities[0]
}

// APIから返ってくるJSONデータに対応するSwiftの構造体
struct WeatherForecast: Decodable {
    let publicTimeFormatted: String
    let descriptionDetail: WeatherDescription
    let forecasts: [Forecast]
    let title: String?

    enum CodingKeys: String, CodingKey {
        case publicTimeFormatted = "publicTime"
        case descriptionDetail = "description"
        case title
        case forecasts
    }

    struct WeatherDescription: Decodable {
        let headlineText: String?
        let bodyText: String?
    }
    
    struct Forecast: Decodable, Identifiable {
        let id = UUID()
        let dateLabel: String
        let telop: String
        let temperature: Temperature
        let chanceOfRain: ChanceOfRain?
        
        enum CodingKeys: String, CodingKey {
            case dateLabel, telop, temperature, chanceOfRain
        }
        
        // ChanceOfRainキーが完全に欠落している場合に対応
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            // 必須項目はtryでデコード
            self.dateLabel = try container.decode(String.self, forKey: .dateLabel)
            self.telop = try container.decode(String.self, forKey: .telop)
            
            // Temperatureはカスタムデコードを使用するため、ここでデコード
            self.temperature = try container.decode(Temperature.self, forKey: .temperature)
            
            // ChanceOfRainはキー自体がAPIに存在しない可能性があるため、decodeIfPresentを使う
            self.chanceOfRain = try container.decodeIfPresent(ChanceOfRain.self, forKey: .chanceOfRain)
        }
        
        // MARK: 【最終修正箇所: Temperatureにカスタムデコードを適用】
        struct Temperature: Decodable {
            let min: Value?
            let max: Value?
            
            enum CodingKeys: String, CodingKey {
                case min, max
            }
            
            // minまたはmaxのキーがJSONに存在しない場合に対応
            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                // decodeIfPresentを使ってキーが存在しない場合はnilを許容する
                self.min = try container.decodeIfPresent(Value.self, forKey: .min)
                self.max = try container.decodeIfPresent(Value.self, forKey: .max)
            }
        }
        
        struct Value: Decodable {
            let celsius: String?
        }
        
        struct ChanceOfRain: Decodable {
            let T00_06: String
            let T06_12: String
            let T12_18: String
            let T18_24: String
        }
    }
}

// MARK: - 2. 状態管理とAPI通信 (従来のURLSession.dataTask形式)

class WeatherState: ObservableObject {
    @Published var selectedCity: City = CityManager.defaultCity
    @Published var forecast: WeatherForecast?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // API通信をキャンセルするためのプロパティ
    private var dataTask: URLSessionDataTask?

    // 地域コードに基づいて天気APIを呼び出し、データを取得する
    func fetchWeather() {
        // 既存の通信があればキャンセル
        dataTask?.cancel()
        
        // MARK: UIの更新は必ずメインスレッドで行う
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        let cityCode = selectedCity.code
        // 日本気象協会のAPI (livedoor) の代替APIを使用
        let urlString = "https://weather.tsukumijima.net/api/forecast?city=\(cityCode)"
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "URLの作成に失敗しました。"
                self.isLoading = false
            }
            return
        }

        // URLSessionを使った従来の非同期通信
        dataTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // UIの更新は必ずメインスレッドで行う
            DispatchQueue.main.async {
                // 処理終了時に必ずローディングを解除
                defer { self.isLoading = false }

                if let error = error {
                    // 通信キャンセルはエラーとして扱わない
                    if (error as NSError).code == NSURLErrorCancelled { return }
                    self.errorMessage = "通信エラー: \(error.localizedDescription)"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "データを受信できませんでした。"
                    return
                }
                
                do {
                    // JSONデコード
                    let decodedForecast = try JSONDecoder().decode(WeatherForecast.self, from: data)
                    self.forecast = decodedForecast
                    self.errorMessage = nil // 成功したのでエラーをクリア
                } catch {
                    // デバッグ用にエラーを表示
                    print("JSON Decode Error: \(error)")
                    // データ構造が間違っている可能性が高いことをユーザーに伝える
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            self.errorMessage = "データのキーが見つかりません: '\(key.stringValue)' - パス: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                        case .typeMismatch(_, let context):
                            self.errorMessage = "データの型が一致しません。パス: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                        case .valueNotFound(_, let context):
                            self.errorMessage = "データが見つかりません。パス: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))"
                        default:
                            self.errorMessage = "データの解析に失敗しました。構造がAPIと一致しません。"
                        }
                    } else {
                        self.errorMessage = "データの解析に失敗しました。構造がAPIと一致しません。"
                    }
                }
            }
        }
        dataTask?.resume() // 通信を開始
    }
}

// MARK: - 3. UIコンポーネントの定義

// 降水確率表示コンポーネント
struct ChanceOfRainView: View {
    let chance: WeatherForecast.Forecast.ChanceOfRain
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("降水確率(%)")
                .font(.caption)
                .foregroundColor(Color(hex: "191970"))
            
            HStack {
                VStack(spacing: 2) { Text("0-6"); Text(chance.T00_06) }.frame(maxWidth: .infinity)
                VStack(spacing: 2) { Text("6-12"); Text(chance.T06_12) }.frame(maxWidth: .infinity)
                VStack(spacing: 2) { Text("12-18"); Text(chance.T12_18) }.frame(maxWidth: .infinity)
                VStack(spacing: 2) { Text("18-24"); Text(chance.T18_24) }.frame(maxWidth: .infinity)
            }
            .font(.footnote)
            .padding(.vertical, 8)
            .background(Color(hex: "e0f7ff"))
            .cornerRadius(8)
        }
    }
}

// 予報タイルコンポーネント
struct ForecastTile: View {
    let forecast: WeatherForecast.Forecast
    
    var body: some View {
        VStack(spacing: 10) {
            Text(forecast.dateLabel)
                .font(.headline)
                .foregroundColor(.white)
            
            Image(systemName: weatherIcon(for: forecast.telop))
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
            
            Text(forecast.telop)
                .font(.subheadline)
                .foregroundColor(.white)
            
            // 最高/最低気温のデータがnilの場合に "--" を表示
            let maxTemp = forecast.temperature.max?.celsius ?? "--"
            let minTemp = forecast.temperature.min?.celsius ?? "--"

            VStack(spacing: 2) {
                Text("最高: \(maxTemp)℃")
                    .foregroundColor(.red)
                Text("最低: \(minTemp)℃")
                    .foregroundColor(.blue)
            }
        }
        .padding(15)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color(hex: "0090ff"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
    }
    
    /// 天気概況からSF Symbolsのアイコン名を決定するヘルパー関数
    func weatherIcon(for telop: String) -> String {
        if telop.contains("晴") && !telop.contains("曇") && !telop.contains("雨") && !telop.contains("雪") {
            return "sun.max.fill"
        } else if telop.contains("曇") {
            return "cloud.fill"
        } else if telop.contains("雨") {
            return "cloud.rain.fill"
        } else if telop.contains("雪") {
            return "cloud.snow.fill"
        } else if telop.contains("雷") {
            return "cloud.bolt.rain.fill"
        } else {
            return "questionmark.circle.fill"
        }
    }
}

// エラー表示コンポーネント
struct ErrorView: View {
    let message: String
    // WeatherStateをEnvironmentObjectとして受け取り、再読み込みを可能にする
    @EnvironmentObject var weatherState: WeatherState
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.largeTitle)
            Text("エラーが発生しました")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                weatherState.fetchWeather() // StateObjectのインスタンスを使って再読み込み
            }) {
                Text("再読み込み")
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color(hex: "ff6347"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


// MARK: - 4. メインビュー

// WiiClassicのお天気チャンネル画面
struct Forecast_ch: View {
    // 状態管理オブジェクトの初期化
    @StateObject var weatherState = WeatherState()
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - ヘッダーと地域選択
            HStack {
                Text("お天気チャンネル")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(Color.blue)
                
                Spacer()
                
                // 地域選択ピッカー
                Picker("地域", selection: $weatherState.selectedCity) {
                    ForEach(CityManager.cities, id: \.self) { city in
                        Text(city.name).tag(city)
                    }
                }
                .onChange(of: weatherState.selectedCity) { _ in
                    weatherState.fetchWeather() // 地域が変わったら即座に通信開始
                }
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
                .shadow(radius: 2)
            }
            .padding()
            .background(Color.white)
            
            // MARK: - メインコンテンツ（天気情報表示）
            if weatherState.isLoading {
                ProgressView("天気予報を取得中...")
                    .scaleEffect(1.5)
                    .foregroundColor(Color(hex: "0090ff"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = weatherState.errorMessage {
                // エラービューにEnvironmentObjectを渡す
                ErrorView(message: errorMessage)
                    .environmentObject(weatherState)
            } else if let forecast = weatherState.forecast {
                ScrollView {
                    VStack(spacing: 25) {
                        // タイトルはOptionalになったため、nilチェック
                        if let title = forecast.title {
                            Text(title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "191970"))
                        }
                        
                        Text("発表時刻: \(forecast.publicTimeFormatted)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        // 3日間の予報のタイル表示
                        HStack(spacing: 15) {
                            ForEach(forecast.forecasts.prefix(3)) { dayForecast in
                                ForecastTile(forecast: dayForecast)
                            }
                        }
                        .padding(.horizontal)
                        
                        Divider().padding(.horizontal)
                        
                        // 詳細情報
                        VStack(alignment: .leading, spacing: 15) {
                            // 降水確率（今日分のみ）
                            // chanceOfRainがnilの場合は表示されない
                            if let todayForecast = forecast.forecasts.first, let chance = todayForecast.chanceOfRain {
                                ChanceOfRainView(chance: chance)
                                    .padding(.bottom, 10)
                            }

                            // 見出し（注意報・警報）
                            if let headline = forecast.descriptionDetail.headlineText {
                                Text("注意報・警報")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                                Text(headline)
                                    .font(.body)
                            }
                            
                            // 詳細な概況
                            if let bodyText = forecast.descriptionDetail.bodyText {
                                Text("概況")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: "191970"))
                                Text(bodyText)
                                    .font(.body)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            } else {
                // 初回ロード時のメッセージと初期データ取得
                VStack {
                    Text("地域を選択して天気予報を表示してください。")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    weatherState.fetchWeather()
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        // 環境オブジェクトとしてWeatherStateを注入 (ErrorView内で再利用できるように)
        .environmentObject(weatherState)
    }
}

// MARK: - Preview (プレビューコード)
struct Forecast_ch_Previews: PreviewProvider {
    static var previews: some View {
        Forecast_ch()
    }
}
