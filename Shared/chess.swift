import SwiftUI

// ======================================================
// 🧠 ロジック＋UIを1ファイルにまとめた簡易チェス
// ======================================================
struct Chess_wiiware: View {
    @StateObject private var chess = ChessBoard()

    var body: some View {
        VStack {
            Text("チェスゲーム")
                .font(.largeTitle)
                .padding(.top, 20)

            Spacer()

            VStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { col in
                            SquareView(
                                piece: chess.board[row][col],
                                isSelected: chess.selectedPosition?.row == row && chess.selectedPosition?.col == col,
                                isDark: (row + col) % 2 == 1
                            )
                            .onTapGesture {
                                chess.select(row: row, col: col)
                            }
                        }
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .border(Color.black, width: 2)
            .padding()

            Button("リセット") {
                chess.resetBoard()
            }
            .padding(.bottom, 30)
        }
    }
}

// ======================================================
// ♟️ チェスロジック部
// ======================================================
enum PieceType: String {
    case pawn = "♙"
    case rook = "♖"
    case knight = "♘"
    case bishop = "♗"
    case queen = "♕"
    case king = "♔"
}

enum Player {
    case white, black
}

struct Piece: Identifiable {
    let id = UUID()
    var type: PieceType
    var player: Player
}

class ChessBoard: ObservableObject {
    @Published var board: [[Piece?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)
    @Published var selectedPosition: (row: Int, col: Int)? = nil

    init() {
        resetBoard()
    }

    func resetBoard() {
        board = Array(repeating: Array(repeating: nil, count: 8), count: 8)

        // 白の駒
        board[7] = [
            Piece(type: .rook, player: .white),
            Piece(type: .knight, player: .white),
            Piece(type: .bishop, player: .white),
            Piece(type: .queen, player: .white),
            Piece(type: .king, player: .white),
            Piece(type: .bishop, player: .white),
            Piece(type: .knight, player: .white),
            Piece(type: .rook, player: .white)
        ]
        board[6] = (0..<8).map { _ in Piece(type: .pawn, player: .white) }

        // 黒の駒
        board[0] = [
            Piece(type: .rook, player: .black),
            Piece(type: .knight, player: .black),
            Piece(type: .bishop, player: .black),
            Piece(type: .queen, player: .black),
            Piece(type: .king, player: .black),
            Piece(type: .bishop, player: .black),
            Piece(type: .knight, player: .black),
            Piece(type: .rook, player: .black)
        ]
        board[1] = (0..<8).map { _ in Piece(type: .pawn, player: .black) }
    }

    func select(row: Int, col: Int) {
        if let selected = selectedPosition {
            movePiece(from: selected, to: (row, col))
            selectedPosition = nil
        } else if board[row][col] != nil {
            selectedPosition = (row, col)
        }
    }

    func movePiece(from: (row: Int, col: Int), to: (row: Int, col: Int)) {
        board[to.row][to.col] = board[from.row][from.col]
        board[from.row][from.col] = nil
    }
}

// ======================================================
// 🎨 マス描画部（Color.brown → カスタム色）
// ======================================================
struct SquareView: View {
    var piece: Piece?
    var isSelected: Bool
    var isDark: Bool

    // 代替色：茶色系（RGB指定）
    private let darkColor = Color(red: 0.6, green: 0.4, blue: 0.2)
    private let lightColor = Color(red: 1.0, green: 0.9, blue: 0.7)

    var body: some View {
        ZStack {
            Rectangle()
                .fill(isDark ? darkColor : lightColor)

            if let piece = piece {
                Text(piece.type.rawValue)
                    .font(.system(size: 30))
                    .foregroundColor(piece.player == .white ? .white : .black)
            }

            if isSelected {
                Rectangle()
                    .stroke(Color.red, lineWidth: 3)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// ======================================================
// 🚀 呼び出し側（他の画面やアプリ内で使えるように）
// ======================================================
struct SimpleChessApp_Preview: PreviewProvider {
    static var previews: some View {
        Chess_wiiware()
            .previewLayout(.device)
    }
}
