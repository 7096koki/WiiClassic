import SwiftUI

// =================================================
// Data models (iOS14-compatible refactor)
// =================================================

enum ItemCategory: String, CaseIterable, Codable {
    case pencil = "鉛筆"
    case eraser = "消しゴム"
    case sharpener = "鉛筆削り/キャップ"
    case pen = "ボールペン/多機能ペン"
    case marker = "マーキングペン/筆ペン"
    case adhesive = "のり/修正テープ"
}

// StationeryItem now stores color as hex string for Codable reliability
struct StationeryItem: Identifiable, Codable {
    let id: String
    let category: ItemCategory
    let name: String
    let price: Int
    let lengthCm: Double
    var quantity: Int

    // store color as hex string for Codable
    var displayColorHex: String

    // computed Color for UI (non-codable)
    var displayColor: Color {
        Color(hex: displayColorHex)
        
    }

    var priceText: String { "\(price)円" }

    init(id: String, category: ItemCategory, name: String, price: Int, lengthCm: Double, displayColorHex: String, quantity: Int = 1) {
        self.id = id
        self.category = category
        self.name = name
        self.price = price
        self.lengthCm = lengthCm
        self.displayColorHex = displayColorHex
        self.quantity = quantity
    }
}

struct PencilCase: Identifiable, Codable {
    var id: String? = UUID().uuidString
    var name: String
    var type: String
    var items: [StationeryItem]

    var totalCost: Int {
        items.reduce(0) { $0 + ($1.price * $1.quantity) }
    }

    init(name: String, type: String = "普段使い", items: [StationeryItem] = []) {
        self.name = name
        self.type = type
        self.items = items
    }
}

struct MockData {
    static let initialItems: [StationeryItem] = [

        // ======================================================
        // MARK: シャーペン（mono graph シリーズ）
        // ======================================================
        StationeryItem(id: "sharp_monograf_fine", category: .pen,
                       name: "MONO graph fine", price: 1320, lengthCm: 14.7, displayColorHex: "FFFFFF"),

        StationeryItem(id: "sharp_monograf_tune", category: .pen,
                       name: "MONO graph TUNE", price: 990, lengthCm: 14.7, displayColorHex: "1E90FF"),

        StationeryItem(id: "sharp_monograf_lite", category: .pen,
                       name: "MONO graph LITE", price: 660, lengthCm: 14.7, displayColorHex: "87CEFA"),

        StationeryItem(id: "sharp_monograf_grip", category: .pen,
                       name: "MONO graph GRIP", price: 880, lengthCm: 14.7, displayColorHex: "0000FF"),

        StationeryItem(id: "sharp_monograf_work", category: .pen,
                       name: "MONO graph WORK", price: 1540, lengthCm: 14.7, displayColorHex: "2F4F4F"),

        // ======================================================
        // MARK: 多機能ペン
        // ======================================================
        StationeryItem(id: "multi_monograf_multi", category: .pen,
                       name: "MONO graph MULTI", price: 1980, lengthCm: 14.8, displayColorHex: "333333"),

        // ======================================================
        // MARK: 消しゴム類（MONO シリーズ）
        // ======================================================
        StationeryItem(id: "eraser_mono_white", category: .eraser,
                       name: "MONO 消しゴム（白）", price: 110, lengthCm: 5.5, displayColorHex: "FFFFFF"),

        StationeryItem(id: "eraser_mono_black", category: .eraser,
                       name: "MONO 消しゴム（ブラック）", price: 110, lengthCm: 5.5, displayColorHex: "000000"),

        StationeryItem(id: "eraser_mono_tough", category: .eraser,
                       name: "MONO タフ", price: 220, lengthCm: 5.5, displayColorHex: "222222"),

        StationeryItem(id: "eraser_mono_light", category: .eraser,
                       name: "MONO ライト", price: 110, lengthCm: 5.5, displayColorHex: "E0E0E0"),

        StationeryItem(id: "eraser_mono_natural", category: .eraser,
                       name: "MONO ナチュラル", price: 150, lengthCm: 5.5, displayColorHex: "C4A484"),

        StationeryItem(id: "eraser_mono_colors", category: .eraser,
                       name: "MONO カラーズ", price: 150, lengthCm: 5.5, displayColorHex: "FF69B4"),

        StationeryItem(id: "eraser_mono_smart", category: .eraser,
                       name: "MONO スマート", price: 150, lengthCm: 6.0, displayColorHex: "B0C4DE"),

        StationeryItem(id: "eraser_mono_airtouch", category: .eraser,
                       name: "MONO エアタッチ", price: 198, lengthCm: 5.5, displayColorHex: "5DADEC"),

        StationeryItem(id: "eraser_mono_dustcatch", category: .eraser,
                       name: "MONO ダストキャッチ", price: 198, lengthCm: 5.5, displayColorHex: "333366"),

        StationeryItem(id: "eraser_mono_nondust", category: .eraser,
                       name: "MONO ノンダスト", price: 180, lengthCm: 5.5, displayColorHex: "AAAAAA"),

        StationeryItem(id: "eraser_mono_easy", category: .eraser,
                       name: "MONO もっとかる～く消せる", price: 200, lengthCm: 5.5, displayColorHex: "00CED1"),

        StationeryItem(id: "eraser_mono_study", category: .eraser,
                       name: "MONO 学習用消しゴム", price: 110, lengthCm: 5.5, displayColorHex: "6495ED"),

        StationeryItem(id: "eraser_mono_sand", category: .eraser,
                       name: "MONO サンド（砂消しゴム）", price: 160, lengthCm: 5.5, displayColorHex: "C2B280"),

        StationeryItem(id: "eraser_monostick", category: .eraser,
                       name: "MONO スティック", price: 180, lengthCm: 11.0, displayColorHex: "FFFFFF"),

        StationeryItem(id: "eraser_monowon", category: .eraser,
                       name: "MONO ワン", price: 240, lengthCm: 7.0, displayColorHex: "0000FF"),

        StationeryItem(id: "eraser_monozero", category: .eraser,
                       name: "MONO ゼロ", price: 330, lengthCm: 12.0, displayColorHex: "FFFFFF"),

        StationeryItem(id: "eraser_ippo_darkpencil", category: .eraser,
                       name: "ippo! 濃いえんぴつ用消しゴム", price: 110, lengthCm: 5.5, displayColorHex: "8B4513"),

        // ======================================================
        // MARK: 既存の商品
        // ======================================================
        StationeryItem(id: "marker_ippo", category: .marker,
                       name: "ippo! なまえペン", price: 165, lengthCm: 14.5, displayColorHex: "0000FF"),

        StationeryItem(id: "glue_pit", category: .adhesive,
                       name: "PiT スティックのり", price: 132, lengthCm: 9.0, displayColorHex: "00B291"),

        StationeryItem(id: "tape_corre", category: .adhesive,
                       name: "MONO 修正テープ", price: 330, lengthCm: 8.0, displayColorHex: "C4003E"),

        StationeryItem(id: "pencil_mono100", category: .pencil,
                       name: "MONO 100 (HB)", price: 165, lengthCm: 17.5, displayColorHex: "000000")
    ]

    static let caseTypes = ["普段使い", "仕事用", "コレクター用", "学生用", "趣味用"]
}



// =================================================
// Main View (PencilCase creator) - iOS14 compatible
// =================================================
struct PencilCaseCreatorView: View {

    @State private var currentPencilCase = PencilCase(name: "My Virtual TOMBOW Case")
    @State private var savedCases: [PencilCase] = []
    @State private var showingItemSelector = false
    @State private var newCaseName: String = "My Virtual TOMBOW Case"
    @State private var selectedCaseType: String = MockData.caseTypes[0]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // MARK: タイトル
                VStack(spacing: 4) {
                    Text("バーチャルペンケースクリエイター")
                        .font(.system(size: 28, weight: .heavy))
                    Text("〜 TOMBOW 文房具で自由に作る 〜")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 10)

                // MARK: ケース設定
                VStack(alignment: .leading, spacing: 12) {

                    Text("ケース設定")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("ケース名")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        TextField("ペンケース名", text: $newCaseName)
                            .padding(10)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(10)
                            .onChange(of: newCaseName) {
                                currentPencilCase.name = $0
                            }

                        Text("タイプ")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Picker("", selection: $selectedCaseType) {
                            ForEach(MockData.caseTypes, id: \.self) { type in
                                Text(type)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(10)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .onChange(of: selectedCaseType) {
                            currentPencilCase.type = $0
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.05), radius: 8)

                // MARK: 合計金額
                VStack {
                    CostSummaryView(currentPencilCase: $currentPencilCase)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.05), radius: 8)

                // MARK: ケースレイアウト
                VStack(alignment: .leading, spacing: 10) {
                    Text("ケース内部イメージ")
                        .font(.headline)

                    PencilCaseLayoutView(items: $currentPencilCase.items)
                        .frame(height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .padding()
                .background(Color.white)
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.05), radius: 8)

                // MARK: ボタン
                HStack(spacing: 20) {

                    Button(action: { showingItemSelector = true }) {
                        Text("文房具を追加")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                            .shadow(color: .green.opacity(0.3), radius: 5)
                    }

                    Button(action: { saveCase() }) {
                        Text("保存")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.3), radius: 5)
                    }
                }
                .padding(.horizontal)

                // MARK: アイテム一覧
                VStack(alignment: .leading, spacing: 8) {
                    Text("選択中の文房具")
                        .font(.headline)

                    ForEach(currentPencilCase.items.indices, id: \.self) { idx in
                        let binding = Binding<StationeryItem>(
                            get: { currentPencilCase.items[idx] },
                            set: { currentPencilCase.items[idx] = $0 }
                        )

                        let item = binding.wrappedValue

                        HStack {
                            Circle()
                                .fill(item.displayColor)
                                .frame(width: 20, height: 20)

                            VStack(alignment: .leading) {
                                Text(item.name)
                                Text(item.priceText)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Stepper(value: binding.quantity, in: 1...100) {
                                Text("\(binding.quantity.wrappedValue)個")
                            }
                        }
                    }
                    .frame(height: 350)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)

            }
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingItemSelector) {
            ItemSelectionView(
                allItems: MockData.initialItems,
                currentItems: $currentPencilCase.items
            )
        }
    }


    func deleteItem(at offsets: IndexSet) {
        currentPencilCase.items.remove(atOffsets: offsets)
    }

    func saveCase() {
        var caseToSave = currentPencilCase
        caseToSave.name = newCaseName
        caseToSave.type = selectedCaseType

        if let index = savedCases.firstIndex(where: { $0.id == currentPencilCase.id }) {
            savedCases[index] = caseToSave
            print("ケースを更新しました: \(caseToSave.name) (ID: \(caseToSave.id ?? "-"))")
        } else {
            caseToSave.id = UUID().uuidString
            savedCases.append(caseToSave)
            print("新しいケースを保存しました: \(caseToSave.name) (ID: \(caseToSave.id ?? "-"))")
        }
    }
}

// =================================================
// Cost summary view (unchanged logic, iOS14-safe)
// =================================================
struct CostSummaryView: View {
    @Binding var currentPencilCase: PencilCase

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("合計金額: \(currentPencilCase.totalCost) 円")
                .font(.title2.bold())
                .foregroundColor(.red)

            DisclosureGroup("内訳 (タップで表示)") {
                VStack(alignment: .leading) {
                    ForEach(currentPencilCase.items) { item in
                        HStack {
                            Text("- \(item.name)")
                            Spacer()
                            Text("\(item.price)円 × \(item.quantity) = \(item.price * item.quantity)円")
                        }
                    }
                    if currentPencilCase.items.isEmpty {
                        Text("アイテムが選択されていません。")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.leading)
            }
        }
        .padding(.horizontal)
    }
}

// =================================================
// Item selection view (iOS14-friendly search)
// =================================================
struct ItemSelectionView: View {
    let allItems: [StationeryItem]
    @Binding var currentItems: [StationeryItem]
    @Environment(\.presentationMode) var presentationMode

    @State private var searchText = ""

    var filteredItems: [StationeryItem] {
        if searchText.isEmpty { return allItems }
        return allItems.filter { $0.name.localizedStandardContains(searchText) }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Search text field (iOS14 replacement for .searchable)
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("アイテムを検索", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding()

                List {
                    ForEach(ItemCategory.allCases, id: \.self) { category in
                        let itemsInCategory = filteredItems.filter { $0.category == category }
                        if !itemsInCategory.isEmpty {
                            Section(header: Text(category.rawValue).font(.headline)) {
                                ForEach(itemsInCategory) { item in
                                    HStack {
                                        Circle()
                                            .fill(item.displayColor)
                                            .frame(width: 15, height: 15)
                                        Text(item.name)
                                        Spacer()
                                        Text(item.priceText)
                                        Button("追加") {
                                            addItem(item)
                                        }
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(6)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarTitle("文房具を選択", displayMode: .inline)
            .navigationBarItems(trailing: Button("閉じる") { presentationMode.wrappedValue.dismiss() })
        }
    }

    func addItem(_ item: StationeryItem) {
        // If exists, increment quantity
        if let index = currentItems.firstIndex(where: { $0.id == item.id }) {
            currentItems[index].quantity += 1
        } else {
            currentItems.append(item)
        }
    }
}

// =================================================
// Pencil case layout simulation (simplified & safe)
// =================================================
struct PencilCaseLayoutView: View {
    @Binding var items: [StationeryItem]
    let totalCaseLength: Double = 20.0

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "D8C4A9") )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.black, lineWidth: 2)
                    )

                VStack(alignment: .leading) {
                    Text("収納率: \(String(format: "%.1f", usagePercentage))%")
                        .font(.caption.bold())
                        .foregroundColor(.black)
                        .padding(.top, 5)
                        .padding(.leading, 10)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(items) { item in
                                let widthRatio = item.lengthCm / totalCaseLength
                                let itemWidth = max(10, geometry.size.width * CGFloat(widthRatio) * CGFloat(item.quantity) * 0.5)

                                VStack {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(item.displayColor)
                                        .frame(width: itemWidth, height: 40)
                                        .overlay(
                                            Text("\(item.quantity)x")
                                                .font(.caption2)
                                                .foregroundColor(item.displayColorHex.lowercased() == "000000" ? .white : .black)
                                        )

                                    Text(String(item.name.prefix(8)) + "...")
                                        .font(.system(size: 8))
                                }
                                .padding(.horizontal, 1)
                            }
                        }
                        .padding(.horizontal, 5)
                        .frame(height: 80, alignment: .top)
                    }
                }
            }
        }
    }

    var usagePercentage: Double {
        let totalItemLength = items.reduce(0) { $0 + ($1.lengthCm * Double($1.quantity)) }
        let maxStorageLength = 25.0
        return min(100.0, (totalItemLength / maxStorageLength) * 100.0)
    }
}

// =================================================
// Entry point: MyPencaseCreator()
// =================================================
struct MyPencaseCreator: View {
    var body: some View {
        PencilCaseCreatorView()
    }
}
