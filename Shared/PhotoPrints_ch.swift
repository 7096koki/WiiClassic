import SwiftUI
import UIKit

// =================================================
// MARK: - Models
// =================================================

enum DigiCamProductType: String, CaseIterable, Identifiable {
    case squareBook = "Wiiフォトブック（スクエア）"
    case standardBook = "Wiiフォトブック（スタンダード）"
    case card = "Wii名刺（写真）"

    var id: String { rawValue }
    
    var pageCount: Int {
        switch self {
        case .squareBook: return 20
        case .standardBook: return 6
        case .card: return 1
        }
    }
}

enum BackgroundTheme: String, CaseIterable, Identifiable {
    case white = "白"
    case black = "黒"
    case wiiCircle = "Wiiサークル" // スクエア用
    case blue = "青" // スタンダード用
    case red = "赤" // スタンダード用
    case formal = "フォーマル" // スタンダード用
    case checkBlue = "水色のチェック"
    case checkPink = "ピンクのチェック"
    case checkBeige = "ベージュのチェック"
    case brown = "茶色" // 名刺用

    var id: String { rawValue }
}

// =================================================
// MARK: - Main View
// =================================================

struct PhotoPrints_ch: View {
    @State private var showCreator = false

    var body: some View {
        ZStack {
            Color(white: 0.9).ignoresSafeArea()
            VStack(spacing: 30) {
                Text("デジカメチャンネル")
                    .font(.system(size: 36, weight: .black))
                    .foregroundColor(.gray)

                Button(action: { showCreator = true }) {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 60))
                        Text("＋ 作成")
                            .font(.title2.bold())
                    }
                    .frame(width: 250, height: 180)
                    .background(Color.white)
                    .foregroundColor(.blue)
                    .cornerRadius(24)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
            }
        }
        .fullScreenCover(isPresented: $showCreator) {
            DigiCamCreateSelectView()
        }
    }
}

// =================================================
// MARK: - Selection View
// =================================================

struct DigiCamCreateSelectView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedType: DigiCamProductType?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("なにを作る？")
                        .font(.title2.bold())
                        .padding(.top)

                    ForEach(DigiCamProductType.allCases) { type in
                        Button {
                            selectedType = type
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(type.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                // 見本プレビュー
                                Rectangle()
                                    .fill(Color(white: 0.95))
                                    .frame(height: 150)
                                    .overlay(
                                        VStack {
                                            Image(systemName: "photo")
                                                .font(.largeTitle)
                                                .foregroundColor(.gray)
                                            Text("見本").font(.caption).foregroundColor(.gray)
                                        }
                                    )
                                    .cornerRadius(8)

                                Text("0円")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(radius: 2)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarTitle("作成", displayMode: .inline)
            .navigationBarItems(leading: Button("もどる") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(item: $selectedType) { type in
                DigiCamEditorView(productType: type)
            }
        }
    }
}

// =================================================
// MARK: - Editor View
// =================================================

struct DigiCamEditorView: View {
    let productType: DigiCamProductType
    @Environment(\.presentationMode) var presentationMode
    
    // State
    @State private var currentPage = 1
    @State private var titleText = "" // 名刺なら名前
    @State private var bodyText = ""  // 名刺なら文章
    @State private var phoneText = "" // 名刺用
    @State private var selectedTheme: BackgroundTheme = .white
    @State private var generatedImage: UIImage?
    @State private var showResult = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Preview Area
                ZStack {
                    Color(white: 0.8)
                    if let img = generatePreviewImage() {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .shadow(radius: 5)
                    }
                }
                .frame(height: 300)
                
                Form {
                    Section(header: Text("ページ・デザイン")) {
                        if productType.pageCount > 1 {
                            Stepper("ページ: \(currentPage) / \(productType.pageCount)", value: $currentPage, in: 1...productType.pageCount)
                        }
                        
                        Picker("背景", selection: $selectedTheme) {
                            ForEach(availableThemes(), id: \.self) { theme in
                                Text(theme.rawValue).tag(theme)
                            }
                        }
                    }
                    
                    Section(header: Text("テキスト入力")) {
                        TextField(productType == .card ? "名前" : "タイトル", text: $titleText)
                        
                        if productType == .card {
                            TextEditor(text: $bodyText)
                                .frame(height: 80)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(white: 0.9)))
                            Text("※3行まで入力想定").font(.caption).foregroundColor(.gray)
                            
                            TextField("電話番号", text: $phoneText)
                        } else {
                            TextField("本文メッセージ", text: $bodyText)
                        }
                    }
                    
                    Button(action: {
                        self.generatedImage = generatePreviewImage(isHighRes: true)
                        self.showResult = true
                    }) {
                        Text("完了（PNGを書き出す）")
                            .frame(maxWidth: .infinity)
                    }
                    .listRowBackground(Color.blue)
                }
            }
            .navigationBarTitle(productType.rawValue, displayMode: .inline)
            .navigationBarItems(trailing: Button("閉じる") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showResult) {
                if let img = generatedImage {
                    ResultDisplayView(image: img)
                }
            }
        }
    }
    
    private func availableThemes() -> [BackgroundTheme] {
        switch productType {
        case .squareBook:
            return [.white, .black, .wiiCircle]
        case .standardBook:
            return [.white, .black, .blue, .red, .formal, .checkBlue, .checkPink, .checkBeige]
        case .card:
            return [.white, .brown]
        }
    }

    // =================================================
    // MARK: - Rendering Engine
    // =================================================
    
    func generatePreviewImage(isHighRes: Bool = false) -> UIImage? {
        let size = isHighRes ? CGSize(width: 1200, height: 900) : CGSize(width: 600, height: 450)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            
            // 1. Background
            drawBackground(ctx: ctx.cgContext, rect: rect)
            
            let textColor: UIColor = (selectedTheme == .black) ? .white : .black
            let accentColor: UIColor = textColor.withAlphaComponent(0.3)
            
            // 2. Content Layout
            switch productType {
            case .squareBook:
                // 中央に写真
                let photoRect = CGRect(x: size.width * 0.2, y: size.height * 0.15, width: size.width * 0.6, height: size.height * 0.5)
                accentColor.setFill()
                ctx.fill(photoRect)
                
                // 下部に文字
                drawText(titleText, at: CGRect(x: 0, y: size.height * 0.7, width: size.width, height: 50), size: size.height * 0.05, color: textColor, align: .center)
                drawText(bodyText, at: CGRect(x: 0, y: size.height * 0.78, width: size.width, height: 40), size: size.height * 0.03, color: textColor, align: .center)
                
            case .standardBook:
                // 上1つ大、下2つ小
                let bigPhoto = CGRect(x: size.width * 0.1, y: size.height * 0.1, width: size.width * 0.8, height: size.height * 0.35)
                let small1 = CGRect(x: size.width * 0.1, y: size.height * 0.5, width: size.width * 0.38, height: size.height * 0.25)
                let small2 = CGRect(x: size.width * 0.52, y: size.height * 0.5, width: size.width * 0.38, height: size.height * 0.25)
                
                accentColor.setFill()
                ctx.fill(bigPhoto)
                ctx.fill(small1)
                ctx.fill(small2)
                
                drawText(titleText, at: CGRect(x: 0, y: size.height * 0.8, width: size.width, height: 40), size: size.height * 0.04, color: textColor, align: .center)

            case .card:
                // 左上 名前
                drawText(titleText, at: CGRect(x: 40, y: 50, width: size.width * 0.5, height: 60), size: size.height * 0.08, color: textColor, align: .left)
                // 左下 文章 (3行まで)
                drawText(bodyText, at: CGRect(x: 40, y: size.height * 0.4, width: size.width * 0.55, height: 150), size: size.height * 0.045, color: textColor, align: .left)
                // さらに下 電話番号
                drawText(phoneText, at: CGRect(x: 40, y: size.height * 0.8, width: size.width * 0.5, height: 40), size: size.height * 0.04, color: textColor, align: .left)
                // 右 写真
                let cardPhoto = CGRect(x: size.width * 0.65, y: 50, width: size.width * 0.3, height: size.height * 0.8)
                accentColor.setFill()
                ctx.fill(cardPhoto)
            }
        }
    }
    
    func drawBackground(ctx: CGContext, rect: CGRect) {
        switch selectedTheme {
        case .white:
            UIColor.white.setFill()
            ctx.fill(rect)
        case .black:
            UIColor.black.setFill()
            ctx.fill(rect)
        case .wiiCircle:
            // Wiiサークル (波紋)
            let colors = [UIColor(red: 0.95, green: 0.98, blue: 1.0, alpha: 1.0).cgColor, UIColor(red: 0.85, green: 0.9, blue: 0.98, alpha: 1.0).cgColor] as CFArray
            let grad = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0.0, 1.0])!
            ctx.drawRadialGradient(grad, startCenter: CGPoint(x: rect.midX, y: rect.midY), startRadius: 0, endCenter: CGPoint(x: rect.midX, y: rect.midY), endRadius: rect.width, options: [])
        case .blue:
            UIColor.systemBlue.setFill(); ctx.fill(rect)
        case .red:
            UIColor.systemRed.setFill(); ctx.fill(rect)
        case .formal:
            UIColor(red: 0.96, green: 0.91, blue: 0.85, alpha: 1.0).setFill(); ctx.fill(rect)
        case .checkBlue, .checkPink, .checkBeige:
            let baseColor = selectedTheme == .checkBlue ? UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0) : (selectedTheme == .checkPink ? UIColor(red: 1.0, green: 0.9, blue: 0.95, alpha: 1.0) : UIColor(red: 0.98, green: 0.95, blue: 0.9, alpha: 1.0))
            baseColor.setFill(); ctx.fill(rect)
            // チェック模様
            ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.6).cgColor)
            ctx.setLineWidth(2)
            let step: CGFloat = rect.width / 15
            for i in stride(from: 0, to: rect.width, by: step) {
                ctx.move(to: CGPoint(x: i, y: 0)); ctx.addLine(to: CGPoint(x: i, y: rect.height))
            }
            for i in stride(from: 0, to: rect.height, by: step) {
                ctx.move(to: CGPoint(x: 0, y: i)); ctx.addLine(to: CGPoint(x: rect.width, y: i))
            }
            ctx.strokePath()
        case .brown:
            UIColor.brown.setFill(); ctx.fill(rect)
        }
    }

    func drawText(_ text: String, at rect: CGRect, size: CGFloat, color: UIColor, align: NSTextAlignment) {
        let style = NSMutableParagraphStyle()
        style.alignment = align
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: size, weight: .medium),
            .foregroundColor: color,
            .paragraphStyle: style
        ]
        text.draw(in: rect, withAttributes: attrs)
    }
}

// =================================================
// MARK: - Result Display View
// =================================================

struct ResultDisplayView: View {
    let image: UIImage
    @Environment(\.presentationMode) var presentationMode
    @State private var saved = false

    var body: some View {
        VStack {
            Text("完成！").font(.title.bold()).padding()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .shadow(radius: 10)
            
            Button(action: {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                saved = true
            }) {
                HStack {
                    Image(systemName: "arrow.down.doc.fill")
                    Text(saved ? "保存しました" : "PNGとして保存")
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(saved ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
            .disabled(saved)

            Button("とじる") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }
}

// =================================================
// MARK: - Previews
// =================================================

struct PhotoPrints_Previews: PreviewProvider {
    static var previews: some View {
        PhotoPrints_ch()
    }
}
