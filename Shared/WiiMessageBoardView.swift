// WiiMessageBoardView.swift

import SwiftUI

// MARK: - Memo Model
// メモのデータを管理するモデル
struct Memo: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var position: CGSize = .zero
}

// MARK: - Wii Message Board View
// メモの作成、表示、編集を管理する画面
struct WiiMessageBoardView: View {
    @State private var memos: [Memo] = []
    @State private var selectedMemo: Memo?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 背景
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            // メモの表示
            // インデックスを使ってループする最も安定した方法
            ForEach(memos.indices, id: \.self) { index in
                MemoView(
                    // バインディングを正しく渡す
                    memo: $memos[index],
                    // タップしたメモを詳細ビューに渡す
                    tapAction: {
                        selectedMemo = memos[index]
                    },
                    // このインデックスのメモを削除するアクション
                    deleteAction: {
                        memos.remove(at: index)
                    }
                )
                .offset(memos[index].position)
            }
            
            // 新規作成ボタン
            Button(action: {
                memos.append(Memo(title: "新しいメモ", content: "ここにテキストを入力してください"))
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .sheet(item: $selectedMemo) { memo in
            MemoDetailView(memo: memo, updateAction: { updatedMemo in
                if let index = memos.firstIndex(where: { $0.id == updatedMemo.id }) {
                    memos[index] = updatedMemo
                }
            }, closeAction: {
                self.selectedMemo = nil
            })
        }
        .navigationTitle("Wii伝言板")
    }
}

// MARK: - Memo View
// 個々のメモカード
struct MemoView: View {
    @Binding var memo: Memo
    var tapAction: () -> Void
    var deleteAction: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ドラッグ用のバーと削除ボタン
            HStack {
                Spacer()
                // 削除ボタン
                Button(action: deleteAction) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .padding(5)
                }
                .frame(alignment: .trailing)
            }
            .frame(height: 25)
            .background(Color(.gray))
            .cornerRadius(25)
            
            // メモの内容
            VStack(alignment: .leading, spacing: 5) {
                Text(memo.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                Text(memo.content)
                    .font(.subheadline)
                    .lineLimit(5)
                    .padding(.horizontal)
            }
            .frame(width: 200, height: 150)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            // コンテンツ部分にのみタップジェスチャーを追加
            .onTapGesture {
                tapAction()
            }
        }
        .offset(dragOffset)
        // ドラッグジェスチャーをVStack全体に適用
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    memo.position.width += value.translation.width
                    memo.position.height += value.translation.height
                    dragOffset = .zero
                }
        )
    }
}

// MARK: - Memo Detail View
// メモをフルスクリーンで表示、編集する画面
struct MemoDetailView: View {
    @State private var editableMemo: Memo
    var updateAction: (Memo) -> Void
    var closeAction: () -> Void
    
    init(memo: Memo, updateAction: @escaping (Memo) -> Void, closeAction: @escaping () -> Void) {
        self._editableMemo = State(initialValue: memo)
        self.updateAction = updateAction
        self.closeAction = closeAction
    }
    
    var body: some View {
        VStack {
            // 閉じるボタン
            HStack {
                Spacer()
                Button("閉じる") {
                    closeAction()
                }
                .padding()
            }
            
            // メモのタイトル（編集可能）
            TextField("タイトル", text: $editableMemo.title)
                .font(.largeTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // メモの内容（編集可能）
            TextEditor(text: $editableMemo.content)
                .font(.body)
                .frame(maxHeight: .infinity)
                .border(Color.gray, width: 1)
                .padding()
        }
        .onDisappear {
            updateAction(editableMemo)
        }
    }
}

// MARK: - Preview
struct WiiMessageBoardView_Previews: PreviewProvider {
    static var previews: some View {
        WiiMessageBoardView()
    }
}
