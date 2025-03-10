import 'package:genetom_chess_engine/genetom_chess_engine.dart';

class ChessData {
  static final List<Map<String, dynamic>> chessPieces = [
    {
      "name": "Pawn",
      "color": "White",
      "num": 1,
      "image": "assets/ChessPiece/white_pawn",
      "count": 0
    },
    {
      "name": "Horse",
      "color": "White",
      "num": 3,
      "image": "assets/ChessPiece/white_horse",
      "count": 0
    },
    {
      "name": "Rook",
      "color": "White",
      "num": 5,
      "image": "assets/ChessPiece/white_rook",
      "count": 0
    },
    {
      "name": "Queen",
      "color": "White",
      "num": 9,
      "image": "assets/ChessPiece/white_queen",
      "count": 0
    },
    {
      "name": "Bishop",
      "color": "White",
      "num": 3,
      "image": "assets/ChessPiece/white_bishop",
      "count": 0
    },
    {
      "name": "Pawn",
      "color": "Black",
      "num": 1,
      "image": "assets/ChessPiece/black_pawn",
      "count": 0
    },
    {
      "name": "Horse",
      "color": "Black",
      "num": 3,
      "image": "assets/ChessPiece/black_horse",
      "count": 0
    },
    {
      "name": "Rook",
      "color": "Black",
      "num": 5,
      "image": "assets/ChessPiece/black_rook",
      "count": 0
    },
    {
      "name": "Queen",
      "color": "Black",
      "num": 9,
      "image": "assets/ChessPiece/black_queen",
      "count": 0
    },
    {
      "name": "Bishop",
      "color": "Black",
      "num": 3,
      "image": "assets/ChessPiece/black_bishop",
      "count": 0
    }
  ];
  static int whiteTotalNumber = 0;
  static int blackTotalNumber = 0;
  static List<CellPosition> unvalidMoves = [];
  static List<CellPosition> tempUnvalidMoves = [];
  static List<int> rowCount = [8, 7, 6, 5, 4, 3, 2, 1];
  static List<int> rowCount1 = [1, 2, 3, 4, 5, 6, 7, 8];
  static List<String> colCount = ["A", "B", "C", "D", "E", "F", "G", "H"];
  static List<String> colCount1 = ["H", "G", "F", "E", "D", "C", "B", "A"];
  static bool invalidMove = false;
  static int selectedPieceIndex = 0;
  // King's positions
  static Map<String, int> whiteKingPositions = {'row': 7, 'col': 4};
  static Map<String, int> blackKingPositions = {'row': 0, 'col': 4};
  static bool attackKing = false;
  static String? lastPieceMoveColor = "black";
  static int unseenMsgCount = 0;
  static bool chessOnline=false;
  static List<MovesLogModel> onlineMoveLogs = [];
  static int fiftyMoveCount =0;
  static bool kingIsUnderCheck = false;
}

List<String> capturedPieceHistory = [];
