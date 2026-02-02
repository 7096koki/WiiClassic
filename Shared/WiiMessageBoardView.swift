import SwiftUI

// MARK: - Memo Model
struct Memo: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var position: CGSize

    init(
        id: UUID = UUID(),
        title: String,
        content: String,
        position: CGSize = .zero
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.position = position
    }
}

// MARK: - Main Board View
struct WiiMessageBoardView: View {
    @State private var memos: [Memo] = []
    @State private var editingMemo: Memo?
    @State private var isCalendarPresented: Bool = false

    var body: some View {
        ZStack {
            // Wii背景（ライトグレー）
            Color(red: 0.95, green: 0.95, blue: 0.95)
                .ignoresSafeArea()

            // 掲示板のメッセージたち
            ForEach(memos) { memo in
                MemoView(
                    memo: memo,
                    onUpdate: { updated in
                        if let index = memos.firstIndex(where: { $0.id == updated.id }) {
                            memos[index] = updated
                        }
                    },
                    onTap: { editingMemo = memo }
                )
            }

            // 下部ナビゲーション
            VStack {
                Spacer()
                HStack(spacing: 20) { // ボタン同士の間隔
                    // カレンダーボタン（左側へ移動）
                    Button(action: { isCalendarPresented = true }) {
                        CircleButton(systemName: "calendar")
                    }
                    
                    // 新規作成ボタン
                    Button(action: addMemo) {
                        CircleButton(systemName: "square.and.pencil")
                    }
                    
                    Spacer() // 右側に寄せる場合はここを調整
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }

            // カレンダーオーバーレイ
            if isCalendarPresented {
                CalendarOverlayView(isPresented: $isCalendarPresented)
                    .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                    .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isCalendarPresented)
        .sheet(item: $editingMemo) { memo in
            MemoDetailView(
                memo: memo,
                onSave: { updated in
                    if let index = memos.firstIndex(where: { $0.id == updated.id }) {
                        memos[index] = updated
                    }
                    editingMemo = nil
                },
                onDelete: { target in
                    memos.removeAll { $0.id == target.id }
                    editingMemo = nil
                }
            )
        }
    }

    private func addMemo() {
        memos.append(Memo(
            title: "新規メッセージ",
            content: "",
            position: CGSize(width: CGFloat.random(in: 40...120), height: CGFloat.random(in: 100...300))
        ))
    }
}

// MARK: - Smart Calendar View
struct CalendarOverlayView: View {
    @Binding var isPresented: Bool
    @State private var selectedDate = Date()
    
    var body: some View {
        ZStack {
            // 背景ブラー
            Color.white.opacity(0.8).ignoresSafeArea()
                .onTapGesture { isPresented = false }

            VStack(spacing: 0) {
                // ヘッダーエリア
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Text("閉じる")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(Capsule().fill(Color.white).shadow(radius: 2))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)

                Spacer()

                // SwiftUI標準のグラフィカルカレンダー
                VStack {
                    DatePicker(
                        "日付を選択",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .accentColor(.gray)
                    .padding(15)
                    
                    HStack {
                        Circle().fill(Color.blue.opacity(0.5)).frame(width: 8, height: 8)
                        Text("印のある日はメッセージが届いています")
                            .font(.system(size: 12, weight: .light))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)
                }
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 30, x: 0, y: 15)
                )
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}

// MARK: - UI Components
struct CircleButton: View {
    let systemName: String
    var body: some View {
        ZStack {
            Circle().fill(Color.white).frame(width: 65, height: 65)
                .shadow(color: .black.opacity(0.1), radius: 5, y: 3)
            Image(systemName: systemName).font(.title2).foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
        }
    }
}

struct MemoView: View {
    let memo: Memo
    var onUpdate: (Memo) -> Void
    var onTap: () -> Void
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        VStack(spacing: -5) {
            // 画鋲
            Circle().fill(Color.red.opacity(0.8)).frame(width: 12, height: 12).zIndex(1)
            
            VStack(alignment: .leading) {
                Text(memo.title).font(.headline).lineLimit(1)
                Divider()
                Text(memo.content.isEmpty ? "内容なし" : memo.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
            .frame(width: 160, height: 160)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 3)
        }
        .offset(x: memo.position.width + dragOffset.width, y: memo.position.height + dragOffset.height)
        .onTapGesture(perform: onTap)
        .gesture(
            DragGesture()
                .onChanged { dragOffset = $0.translation }
                .onEnded { value in
                    var new = memo
                    new.position.width += value.translation.width
                    new.position.height += value.translation.height
                    dragOffset = .zero
                    onUpdate(new)
                }
        )
    }
}

struct MemoDetailView: View {
    @State var memo: Memo
    var onSave: (Memo) -> Void
    var onDelete: (Memo) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("タイトル", text: $memo.title)
                    TextEditor(text: $memo.content)
                        .frame(minHeight: 200)
                }
            }
            .navigationTitle("編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // 左側にゴミ箱アイコン
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { onDelete(memo) }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                // 右側に保存ボタン
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        onSave(memo)
                    }
                }
            }
        }
    }
}
