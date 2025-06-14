// ignore_for_file: file_names

/// This dentotes the chess piece.
enum ChessPiece { pawn, rook, bishop, horse, queen, king, emptyCell }

///This dentotes the gameover status.
enum GameOver { whiteWins, blackWins, draw }

///This denotes the difficulty.
enum Difficulty { tooEasy, easy, medium, hard, asian }

/// Mapping each piece with its power.
Map<ChessPiece, int> chessPieceValue = {
  ChessPiece.pawn: pawnPower,
  ChessPiece.rook: rookPower,
  ChessPiece.bishop: bishopPower,
  ChessPiece.horse: horsePower,
  ChessPiece.queen: queenPower,
  ChessPiece.king: kingPower,
  ChessPiece.emptyCell: emptyCellPower,
};

const int pawnPower = 100;
const int horsePower = 320;
const int bishopPower = 330;
const int rookPower = 500;
const int queenPower = 900;
const int kingPower = 20000;
const int emptyCellPower = 0;

//Square table value.
const List<List<double>> pawnSquareTable = [
  [0, 0, 0, 0, 0, 0, 0, 0],
  [50, 50, 50, 50, 50, 50, 50, 50],
  [10, 10, 20, 30, 30, 20, 10, 10],
  [5, 5, 10, 25, 25, 10, 5, 5],
  [0, 0, 0, 20, 20, 0, 0, 0],
  [5, -5, -10, 0, 0, -10, -5, 5],
  [5, 10, 10, -20, -20, 10, 10, 5],
  [0, 0, 0, 0, 0, 0, 0, 0]
];

///Horse Square Table.
const List<List<double>> horseSquareTable = [
  [-50, -40, -30, -30, -30, -30, -40, -50],
  [-40, -20, 0, 0, 0, 0, -20, -40],
  [-30, 0, 10, 15, 15, 10, 0, -30],
  [-30, 5, 15, 20, 20, 15, 5, -30],
  [-30, 0, 15, 20, 20, 15, 0, -30],
  [-30, 5, 10, 15, 15, 10, 5, -30],
  [-40, -20, 0, 5, 5, 0, -20, -40],
  [-50, -40, -30, -30, -30, -30, -40, -50],
];

///Bishop Square Table.
const List<List<double>> bishopSquareTable = [
  [-20, -10, -10, -10, -10, -10, -10, -20],
  [-10, 0, 0, 0, 0, 0, 0, -10],
  [-10, 0, 5, 10, 10, 5, 0, -10],
  [-10, 5, 5, 10, 10, 5, 5, -10],
  [-10, 0, 10, 10, 10, 10, 0, -10],
  [-10, 10, 10, 10, 10, 10, 10, -10],
  [-10, 5, 0, 0, 0, 0, 5, -10],
  [-20, -10, -10, -10, -10, -10, -10, -20],
];

/// Queen Square Table.
const List<List<double>> queenSquareTable = [
  [-20, -10, -10, -5, -5, -10, -10, -20],
  [-10, 0, 0, 0, 0, 0, 0, -10],
  [-10, 0, 5, 5, 5, 5, 0, -10],
  [-5, 0, 5, 5, 5, 5, 0, -5],
  [0, 0, 5, 5, 5, 5, 0, -5],
  [-10, 5, 5, 5, 5, 5, 0, -10],
  [-10, 0, 5, 0, 0, 0, 0, -10],
  [-20, -10, -10, -5, -5, -10, -10, -20]
];

/// Piece-square table for kings (early/mid game).
const List<List<double>> kingMidGameSquareTable = [
  [-30, -40, -40, -50, -50, -40, -40, -30],
  [-30, -40, -40, -50, -50, -40, -40, -30],
  [-30, -40, -40, -50, -50, -40, -40, -30],
  [-30, -40, -40, -50, -50, -40, -40, -30],
  [-20, -30, -30, -40, -40, -30, -30, -20],
  [-10, -20, -20, -20, -20, -20, -20, -10],
  [20, 20, 0, 0, 0, 0, 20, 20],
  [20, 30, 10, 0, 0, 10, 30, 20]
];

///King EndGame Square table.
const List<List<double>> kingEndGameSquareTable = [
  [-50, -40, -30, -20, -20, -30, -40, -50],
  [-30, -20, -10, 0, 0, -10, -20, -30],
  [-30, -10, 20, 30, 30, 20, -10, -30],
  [-30, -10, 30, 40, 40, 30, -10, -30],
  [-30, -10, 30, 40, 40, 30, -10, -30],
  [-30, -10, 20, 30, 30, 20, -10, -30],
  [-30, -30, 0, 0, 0, 0, -30, -30],
  [-50, -30, -30, -30, -30, -30, -30, -50]
];

///Rook Square Table.
const List<List<double>> rookSquareTable = [
  [0, 0, 0, 0, 0, 0, 0, 0],
  [5, 10, 10, 10, 10, 10, 10, 5],
  [-5, 0, 0, 0, 0, 0, 0, -5],
  [-5, 0, 0, 0, 0, 0, 0, -5],
  [-5, 0, 0, 0, 0, 0, 0, -5],
  [-5, 0, 0, 0, 0, 0, 0, -5],
  [-5, 0, 0, 0, 0, 0, 0, -5],
  [0, 0, 0, 5, 5, 0, 0, 0]
];

///Chess Config Model.
class ChessConfig {
  String fenString;
  Difficulty difficulty;
  bool isPlayerAWhite;
  ChessConfig(
      {required this.isPlayerAWhite,
      this.fenString = '',
      this.difficulty = Difficulty.easy});
}

///This defines the posistion of a piece in a 2D array.
class CellPosition {
  int row;
  int col;
  CellPosition({required this.row, required this.col});
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CellPosition && other.row == row && other.col == col;
  }

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

///This defines the moves.
class MovesModel {
  CellPosition currentPosition;
  CellPosition targetPosition;
  MovesModel({required this.currentPosition, required this.targetPosition});
}

///This is for Move logs.
class MovesLogModel {
  int piece;
  MovesModel move;
  MovesLogModel({required this.move, required this.piece});
}

///This is for calculate score, if we performed that move.
class MoveScore {
  MovesModel? move;
  double score;
  MoveScore({required this.move, required this.score});
}

class ChessEngineHelpers {
  static List<List<int>> deepCopyBoard(List<List<int>> original) {
    List<List<int>> copy = [];
    for (int i = 0; i < original.length; i++) {
      List<int> rowCopy = [];
      for (int j = 0; j < original[i].length; j++) {
        rowCopy.add(original[i][j]);
      }
      copy.add(rowCopy);
    }
    return copy;
  }

  static List<List<double>> deepCopyAndReversePositionTable(
      List<List<double>> original) {
    List<List<double>> copy = [];
    for (int i = 0; i < original.length; i++) {
      List<double> rowCopy = [];
      for (int j = 0; j < original[i].length; j++) {
        rowCopy.add(original[i][j]);
      }
      copy.add(rowCopy);
    }
    for (List<double> ele in copy) {
      ele = ele.reversed.toList();
    }
    copy = copy.reversed.toList();
    return copy;
  }

  static List<List<int>> deepCopyAndReverseBoard(List<List<int>> original) {
    List<List<int>> copy = [];
    for (int i = 0; i < original.length; i++) {
      List<int> rowCopy = [];
      for (int j = 0; j < original[i].length; j++) {
        rowCopy.add(original[i][j]);
      }
      copy.add(rowCopy);
    }
    for (List<int> ele in copy) {
      ele = ele.reversed.toList();
    }
    copy = copy.reversed.toList();
    return copy;
  }
}
