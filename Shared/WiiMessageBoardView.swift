// WiiMessageBoardView.swift

import SwiftUI

// MARK: - メモモデル
// メモのデータを管理するモデル
struct Memo: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var position: CGSize = .zero
}

// MARK: - Wii伝言板ビュー
// メモの作成、表示、編集を管理する画面
struct WiiMessageBoardView: View {
    @State private var memos: [Memo] = []
    @State private var showingMemoDetail = false
    @State private var selectedMemo: Memo?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // 背景
            Color(.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            // メモの表示
            ForEach(memos.indices, id: \.self) { index in
                MemoView(memo: $memos[index], onRemove: {
                    memos.remove(at: index)
                })
                .offset(memos[index].position)
                .onTapGesture {
                    selectedMemo = memos[index]
                    showingMemoDetail = true
                }
            }
            
            // 新規作成ボタン
            Button(action: {
                // 新しいメモを作成し、リストに追加
                memos.append(Memo(title: "新規メモ", content: "テキストをタップして編集"))
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .sheet(isPresented: $showingMemoDetail) {
            if let selectedMemo = selectedMemo {
                MemoDetailView(memo: selectedMemo, onUpdate: { updatedMemo in
                    if let index = memos.firstIndex(where: { $0.id == updatedMemo.id }) {
                        memos[index] = updatedMemo
                    }
                })
            }
        }
        .navigationTitle("Wii伝言板")
    }
}

// MARK: - メモビュー
// 個々のメモカード
struct MemoView: View {
    @Binding var memo: Memo
    var onRemove: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ドラッグ用のバー
            HStack {
                Spacer()
                // 削除ボタン
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .padding(5)
                }
            }
            .frame(height: 20)
            .background(Color(.gray))
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
        }
        .offset(dragOffset)
    }
}

// MARK: - メモ詳細ビュー
// メモをフルスクリーンで表示、編集する画面
struct MemoDetailView: View {
    // @Environment(\.dismiss) var dismiss
    @State private var editableMemo: Memo
    var onUpdate: (Memo) -> Void
    
    init(memo: Memo, onUpdate: @escaping (Memo) -> Void) {
        self._editableMemo = State(initialValue: memo)
        self.onUpdate = onUpdate
    }
    
    var body: some View {
        VStack {
            // 閉じるボタン
            HStack {
                Spacer()
                Button("閉じる") {
                    // ここでモーダルを閉じる
                    // dismiss()
                }
                .padding()
            }
            
            // メモのタイトル（編集可能）
            TextField("タイトル", text: $editableMemo.title)
                .font(.largeTitle)
                // .fontWeight(.bold)
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
            // 画面が閉じるときに内容を更新
            onUpdate(editableMemo)
        }
    }
}

// MARK: - プレビュー
struct WiiMessageBoardView_Previews: PreviewProvider {
    static var previews: some View {
        WiiMessageBoardView()
    }
}
