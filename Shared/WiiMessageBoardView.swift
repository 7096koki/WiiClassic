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

// MARK: - Wii Message Board View
struct WiiMessageBoardView: View {
    @State private var memos: [Memo] = []
    @State private var selectedMemo: Memo?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(.systemGray6)
                .ignoresSafeArea()

            // メモ一覧（index安全版）
            ForEach(memos.indices, id: \.self) { index in
                MemoView(
                    memo: $memos[index],
                    tapAction: {
                        selectedMemo = memos[index]
                    }
                )
            }

            // 新規メモ追加ボタン
            Button {
                memos.append(
                    Memo(
                        title: "新しいメモ",
                        content: "ここにテキストを入力してください"
                    )
                )
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .sheet(item: $selectedMemo) { memo in
            MemoDetailView(
                memo: memo,
                updateAction: updateMemo,
                closeAction: { selectedMemo = nil }
            )
        }
        .navigationTitle("Wii伝言板")
    }

    // MARK: - Update
    private func updateMemo(_ updated: Memo) {
        if let index = memos.firstIndex(where: { $0.id == updated.id }) {
            memos[index] = updated
        }
    }
}

// MARK: - Memo View
struct MemoView: View {
    @Binding var memo: Memo
    var tapAction: () -> Void

    @State private var dragOffset: CGSize = .zero

    private let memoWidth: CGFloat = 200
    private let memoHeight: CGFloat = 140

    var body: some View {
        VStack(spacing: 0) {

            // 🔴 プッシュピン（最前面）
            ZStack {
                Color.clear
                    .frame(width: memoWidth, height: 20)

                Circle()
                    .fill(Color.red)
                    .frame(width: 22, height: 22)
                    .offset(y: 6) // 上端に触れる程度
                    .shadow(color: .black.opacity(0.35), radius: 3, x: 0, y: 2)
            }
            .zIndex(1)

            // メモ本体
            VStack(alignment: .leading, spacing: 6) {
                Text(memo.title)
                    .font(.headline)

                Text(memo.content)
                    .font(.subheadline)
                    .lineLimit(4)
            }
            .padding()
            .frame(width: memoWidth, height: memoHeight)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 4)
            .onTapGesture { tapAction() }
            .zIndex(0)
        }
        .offset(
            x: memo.position.width + dragOffset.width,
            y: memo.position.height + dragOffset.height
        )
        .gesture(
            DragGesture()
                .onChanged { dragOffset = $0.translation }
                .onEnded {
                    memo.position.width += $0.translation.width
                    memo.position.height += $0.translation.height
                    dragOffset = .zero
                }
        )
    }
}

// MARK: - Memo Detail View
struct MemoDetailView: View {
    @State private var editableMemo: Memo
    var updateAction: (Memo) -> Void
    var closeAction: () -> Void

    init(
        memo: Memo,
        updateAction: @escaping (Memo) -> Void,
        closeAction: @escaping () -> Void
    ) {
        _editableMemo = State(initialValue: memo)
        self.updateAction = updateAction
        self.closeAction = closeAction
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("閉じる") {
                    updateAction(editableMemo)
                    closeAction()
                }
                .padding()
            }

            TextField("タイトル", text: $editableMemo.title)
                .font(.title)
                .padding()

            TextEditor(text: $editableMemo.content)
                .padding()
        }
    }
}
