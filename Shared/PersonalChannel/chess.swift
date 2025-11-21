import SwiftUI

struct Chess_wiiware: View {
    @StateObject private var chess = ChessBoard()

    var body: some View {
        VStack {
            Text("チェスゲーム")
                .font(.largeTitle)
                .bold()
                .padding(.top, 20)

            Text(chess.statusText)
                .font(.headline)
                .foregroundColor(.red)
                .padding(.bottom, 5)

            VStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { col in
                            SquareView(
                                piece: chess.board[row][col],
                                isSelected: chess.selectedPosition?.0 == row && chess.selectedPosition?.1 == col,
                                isDark: (row + col) % 2 == 1,
                                isHighlighted: chess.highlightedPositions.contains { $0.0 == row && $0.1 == col }
                            )
                            .onTapGesture {
                                chess.selectOrMove(row: row, col: col)
                            }
                        }
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .border(Color.black, width: 2)
            .padding(10)

            HStack {
                Button("リセット") {
                    chess.resetBoard()
                }
                .padding()
                Text("ターン: \(chess.currentTurn == .white ? "白" : "黒")")
                    .font(.headline)
            }
            .padding(.bottom, 30)
        }
    }
}

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
    var next: Player { self == .white ? .black : .white }
}

struct Piece: Identifiable {
    let id = UUID()
    var type: PieceType
    var player: Player
    var hasMoved: Bool = false
}

class ChessBoard: ObservableObject {
    @Published var board: [[Piece?]] = Array(repeating: Array(repeating: nil, count: 8), count: 8)
    @Published var selectedPosition: (Int, Int)? = nil
    @Published var highlightedPositions: [(Int, Int)] = []
    @Published var currentTurn: Player = .white
    @Published var statusText: String = ""
    private var lastMove: ((from: (Int, Int), to: (Int, Int), piece: Piece))? = nil

    init() { resetBoard() }

    func resetBoard() {
        currentTurn = .white
        statusText = ""
        selectedPosition = nil
        highlightedPositions = []

        let backRow: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
        board = Array(repeating: Array(repeating: nil, count: 8), count: 8)
        board[0] = backRow.map { Piece(type: $0, player: .black) }
        board[1] = (0..<8).map { _ in Piece(type: .pawn, player: .black) }
        board[6] = (0..<8).map { _ in Piece(type: .pawn, player: .white) }
        board[7] = backRow.map { Piece(type: $0, player: .white) }
    }

    func selectOrMove(row: Int, col: Int) {
        if highlightedPositions.contains(where: { $0.0 == row && $0.1 == col }) {
            movePiece(to: (row, col))
        } else if let piece = board[row][col], piece.player == currentTurn {
            selectedPosition = (row, col)
            highlightedPositions = legalMoves(for: piece, at: (row, col))
        } else {
            selectedPosition = nil
            highlightedPositions = []
        }
    }

    func movePiece(to pos: (Int, Int)) {
        guard let from = selectedPosition,
              var movingPiece = board[from.0][from.1] else { return }

        // アンパッサン
        if movingPiece.type == .pawn && abs(pos.0 - from.0) == 1 && abs(pos.1 - from.1) == 1 && board[pos.0][pos.1] == nil {
            board[from.0][pos.1] = nil
        }

        // キャスリング
        if movingPiece.type == .king && abs(pos.1 - from.1) == 2 {
            let rookCol = pos.1 == 6 ? 7 : 0
            let newRookCol = pos.1 == 6 ? 5 : 3
            if let rook = board[from.0][rookCol] {
                board[from.0][newRookCol] = Piece(type: .rook, player: currentTurn, hasMoved: true)
                board[from.0][rookCol] = nil
            }
        }

        board[pos.0][pos.1] = Piece(type: movingPiece.type, player: movingPiece.player, hasMoved: true)
        board[from.0][from.1] = nil
        lastMove = (from, pos, movingPiece)

        // プロモーション
        if movingPiece.type == .pawn && (pos.0 == 0 || pos.0 == 7) {
            board[pos.0][pos.1]?.type = .queen
        }

        selectedPosition = nil
        highlightedPositions = []
        currentTurn = currentTurn.next

        if isCheckmate(for: currentTurn) {
            statusText = "\(currentTurn == .white ? "白" : "黒")のチェックメイト！"
        } else if isInCheck(player: currentTurn) {
            statusText = "\(currentTurn == .white ? "白" : "黒")はチェック中！"
        } else {
            statusText = ""
        }
    }

    func legalMoves(for piece: Piece, at pos: (Int, Int)) -> [(Int, Int)] {
        var moves: [(Int, Int)] = []
        for move in possibleMoves(for: piece, at: pos) {
            if !wouldBeInCheck(piece: piece, from: pos, to: move) {
                moves.append(move)
            }
        }
        return moves
    }

    private func wouldBeInCheck(piece: Piece, from: (Int, Int), to: (Int, Int)) -> Bool {
        let backupTo = board[to.0][to.1]
        let backupFrom = board[from.0][from.1]
        board[to.0][to.1] = backupFrom
        board[from.0][from.1] = nil
        let result = isInCheck(player: piece.player)
        board[from.0][from.1] = backupFrom
        board[to.0][to.1] = backupTo
        return result
    }

    // ========= ここから追加！ =========

    func possibleMoves(for piece: Piece, at pos: (Int, Int)) -> [(Int, Int)] {
        var moves: [(Int, Int)] = []
        let directions = [
            (1,0),(-1,0),(0,1),(0,-1),(1,1),(1,-1),(-1,1),(-1,-1)
        ]
        func inside(_ r: Int, _ c: Int) -> Bool { (0..<8).contains(r) && (0..<8).contains(c) }

        switch piece.type {
        case .pawn:
            let dir = piece.player == .white ? -1 : 1
            let startRow = piece.player == .white ? 6 : 1
            let next = pos.0 + dir
            if inside(next,pos.1) && board[next][pos.1] == nil {
                moves.append((next,pos.1))
                if pos.0 == startRow && board[next+dir][pos.1] == nil {
                    moves.append((next+dir,pos.1))
                }
            }
            for dc in [-1,1] {
                let c = pos.1 + dc
                if inside(next,c), let target = board[next][c], target.player != piece.player {
                    moves.append((next,c))
                }
            }
        case .rook:
            moves.append(contentsOf: linearMoves(from: pos, deltas: [(1,0),(-1,0),(0,1),(0,-1)], for: piece))
        case .bishop:
            moves.append(contentsOf: linearMoves(from: pos, deltas: [(1,1),(1,-1),(-1,1),(-1,-1)], for: piece))
        case .queen:
            moves.append(contentsOf: linearMoves(from: pos, deltas: directions, for: piece))
        case .king:
            for (dr,dc) in directions {
                let r = pos.0+dr, c = pos.1+dc
                if inside(r,c) && (board[r][c]?.player != piece.player) {
                    moves.append((r,c))
                }
            }
        case .knight:
            let jumps = [(2,1),(1,2),(-1,2),(-2,1),(-2,-1),(-1,-2),(1,-2),(2,-1)]
            for (dr,dc) in jumps {
                let r = pos.0+dr, c = pos.1+dc
                if inside(r,c) && (board[r][c]?.player != piece.player) {
                    moves.append((r,c))
                }
            }
        }
        return moves
    }

    func linearMoves(from pos: (Int,Int), deltas: [(Int,Int)], for piece: Piece) -> [(Int,Int)] {
        var moves: [(Int,Int)] = []
        for (dr,dc) in deltas {
            var r = pos.0 + dr
            var c = pos.1 + dc
            while (0..<8).contains(r) && (0..<8).contains(c) {
                if let target = board[r][c] {
                    if target.player != piece.player { moves.append((r,c)) }
                    break
                } else {
                    moves.append((r,c))
                }
                r += dr
                c += dc
            }
        }
        return moves
    }

    func isInCheck(player: Player) -> Bool {
        var kingPos: (Int,Int)? = nil
        for r in 0..<8 {
            for c in 0..<8 {
                if let piece = board[r][c], piece.type == .king, piece.player == player {
                    kingPos = (r,c)
                }
            }
        }
        guard let king = kingPos else { return false }

        for r in 0..<8 {
            for c in 0..<8 {
                if let piece = board[r][c], piece.player != player {
                    if possibleMoves(for: piece, at: (r,c)).contains(where: { $0 == king }) {
                        return true
                    }
                }
            }
        }
        return false
    }

    func isCheckmate(for player: Player) -> Bool {
        if !isInCheck(player: player) { return false }
        for r in 0..<8 {
            for c in 0..<8 {
                if let piece = board[r][c], piece.player == player {
                    if !legalMoves(for: piece, at: (r,c)).isEmpty {
                        return false
                    }
                }
            }
        }
        return true
    }
}

// ======= 駒とマスを描画するビュー =======

struct SquareView: View {
    var piece: Piece?
    var isSelected: Bool
    var isDark: Bool
    var isHighlighted: Bool

    private let darkColor = Color(red: 0.6, green: 0.4, blue: 0.2)
    private let lightColor = Color(red: 1.0, green: 0.9, blue: 0.7)

    var body: some View {
        ZStack {
            Rectangle().fill(isDark ? darkColor : lightColor)
            if let piece = piece {
                Text(piece.type.rawValue)
                    .font(.system(size: 36))
                    .fontWeight(.bold)
                    .foregroundColor(piece.player == .white ? .black : .white)
            }
            if isHighlighted {
                Rectangle().fill(Color.red.opacity(0.25))
            } else if isSelected {
                Rectangle().stroke(Color.red, lineWidth: 3)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
