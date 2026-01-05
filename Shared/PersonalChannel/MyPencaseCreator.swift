import SwiftUI

// =================================================
// Data models
// =================================================

enum ItemCategory: String, CaseIterable, Codable, Identifiable {
    case pencil = "鉛筆"
    case eraser = "消しゴム"
    case sharpener = "鉛筆削り/キャップ"
    case pen = "ボールペン/多機能ペン"
    case marker = "マーキングペン/筆ペン"
    case adhesive = "のり/修正テープ"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .pencil: return "pencil"
        case .eraser: return "square.fill"
        case .sharpener: return "scissors"
        case .pen: return "pencil.tip"
        case .marker: return "highlighter"
        case .adhesive: return "bandage.fill"
        }
    }
}

struct StationeryItem: Identifiable, Codable, Equatable {
    let id: String
    let category: ItemCategory
    let name: String
    let price: Int
    let lengthCm: Double
    var quantity: Int
    var displayColorHex: String

    var displayColor: Color {
        Color(hex: displayColorHex)
    }

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

// =================================================
// View Model
// =================================================

class PencilCaseStore: ObservableObject {
    @Published var items: [StationeryItem] = []
    @Published var caseName: String = "マイ・ベスト・ペンケース"
    @Published var selectedType: String = "普段使い"
    
    var totalCost: Int {
        items.reduce(0) { $0 + ($1.price * $1.quantity) }
    }
    
    var usagePercentage: Double {
        let totalLen = items.reduce(0) { $0 + ($1.lengthCm * Double($1.quantity)) }
        let capacity = 40.0 // 収納限界
        return min(100.0, (totalLen / capacity) * 100.0)
    }
    
    func addItem(_ item: StationeryItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].quantity += 1
        } else {
            items.append(item)
        }
    }
    
    func removeItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
}

// =================================================
// Main View
// =================================================

struct MyPencaseCreator: View {
    @StateObject private var store = PencilCaseStore()
    @State private var showingSelector = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        // --- ケースのビジュアル表示 ---
                        PencilCasePreviewCard(store: store)
                        
                        // --- 設定セクション ---
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("ケース設定")
                                    .font(.headline)
                                Spacer()
                                Text("合計: \(store.totalCost)円")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }
                            
                            TextField("ペンケース名を入力", text: $store.caseName)
                                .padding(12)
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(10)
                            
                            // iOS 14のPicker
                            Picker("タイプ", selection: $store.selectedType) {
                                ForEach(["普段使い", "学校用", "お絵描き用", "本気"], id: \.self) {
                                    Text($0).tag($0)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        
                        // --- アイテムリスト ---
                        VStack(alignment: .leading, spacing: 8) {
                            Text("中身のリスト")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if store.items.isEmpty {
                                Text("右下のボタンから文房具を追加")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, minHeight: 100)
                            } else {
                                ForEach(store.items) { item in
                                    StationeryRow(item: item, store: store)
                                }
                            }
                        }
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
                
                // --- アクションボタン ---
                Button(action: { showingSelector = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("文房具を追加する")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(16)
                    .padding()
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
            }
            .navigationTitle("Pencase Creator")
            .sheet(isPresented: $showingSelector) {
                ItemPickerView(store: store)
            }
        }
    }
}

// --- 個別アイテム行 ---
struct StationeryRow: View {
    let item: StationeryItem
    @ObservedObject var store: PencilCaseStore
    
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(item.displayColor)
                .frame(width: 8, height: 32)
            
            VStack(alignment: .leading) {
                Text(item.name).font(.system(.body, design: .rounded).bold())
                Text("\(item.price)円").font(.caption).foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 15) {
                Button(action: { updateQty(-1) }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                }
                Text("\(item.quantity)").font(.system(.body, design: .monospaced))
                Button(action: { updateQty(1) }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
            .foregroundColor(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func updateQty(_ delta: Int) {
        if let idx = store.items.firstIndex(of: item) {
            let newVal = store.items[idx].quantity + delta
            if newVal <= 0 {
                withAnimation {
                    store.items.remove(at: idx)
                }
            } else {
                store.items[idx].quantity = newVal
            }
        }
    }
}

// --- ペンケースのプレビュー ---
struct PencilCasePreviewCard: View {
    @ObservedObject var store: PencilCaseStore
    
    // iOS 14ではカスタムLayoutがないためLazyVGridで代用
    let columns = [GridItem(.adaptive(minimum: 40))]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Pencase View").font(.caption.bold()).foregroundColor(.secondary)
                Spacer()
                Text("収納率: \(Int(store.usagePercentage))%").font(.caption.bold())
                    .foregroundColor(store.usagePercentage > 90 ? .red : .blue)
            }
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color(hex: "E8E8E8"), Color(hex: "CCCCCC")]), startPoint: .top, endPoint: .bottom))
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(store.items) { item in
                            ForEach(0..<item.quantity, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(item.displayColor)
                                    .frame(height: 8)
                                    .frame(width: CGFloat(item.lengthCm * 3))
                            }
                        }
                    }
                    .padding()
                }
            }
            .frame(height: 140)
        }
    }
}

// --- アイテム選択画面 (iOS 14互換) ---
struct ItemPickerView: View {
    @ObservedObject var store: PencilCaseStore
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    
    let allItems = MockData.initialItems
    
    var filteredItems: [StationeryItem] {
        if searchText.isEmpty { return allItems }
        return allItems.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 自作検索バー (iOS 14用)
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("文房具を検索", text: $searchText)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                        }
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                List {
                    ForEach(ItemCategory.allCases) { cat in
                        let items = filteredItems.filter { $0.category == cat }
                        if !items.isEmpty {
                            Section(header: Text(cat.rawValue)) {
                                ForEach(items) { item in
                                    Button(action: {
                                        withAnimation { store.addItem(item) }
                                    }) {
                                        HStack {
                                            Circle().fill(item.displayColor).frame(width: 8)
                                            VStack(alignment: .leading) {
                                                Text(item.name).foregroundColor(.primary)
                                                Text("\(item.price)円").font(.caption).foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Image(systemName: "plus")
                                                .font(.caption.bold())
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("カタログ")
            .navigationBarItems(trailing: Button("閉じる") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// =================================================
// Utilities
// =================================================


struct MockData {
    static let initialItems: [StationeryItem] = [
        StationeryItem(id: "s1", category: .pen, name: "MONO graph fine", price: 1320, lengthCm: 14.7, displayColorHex: "222222"),
        StationeryItem(id: "s2", category: .pen, name: "MONO graph TUNE", price: 990, lengthCm: 14.7, displayColorHex: "3B82F6"),
        StationeryItem(id: "e1", category: .eraser, name: "MONO 消しゴム", price: 110, lengthCm: 5.5, displayColorHex: "FFFFFF"),
        StationeryItem(id: "e2", category: .eraser, name: "MONO ブラック", price: 110, lengthCm: 5.5, displayColorHex: "111111"),
        StationeryItem(id: "a1", category: .adhesive, name: "PiT スティックのり", price: 132, lengthCm: 9.0, displayColorHex: "10B981"),
        StationeryItem(id: "p1", category: .pencil, name: "MONO 100", price: 165, lengthCm: 17.5, displayColorHex: "1F2937")
    ]
}

struct MyPencaseCreator_Previews: PreviewProvider {
    static var previews: some View {
        MyPencaseCreator()
    }
}
