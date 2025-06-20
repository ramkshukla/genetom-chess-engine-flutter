// ignore_for_file: file_names

import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:genetom_chess_engine/src/chess_engine_core.dart';
import 'package:genetom_chess_engine/src/online_chess_data.dart';
import 'package:genetom_chess_engine/src/valid_moves.dart';
import 'package:genetom_chess_engine/src/chess_data.dart';

class ChessEngine {
  //Position tables
  List<List<double>> _whitePawnTable = [];
  List<List<double>> _whiteHorseTable = [];
  List<List<double>> _whiteBishopTable = [];
  List<List<double>> _whiteRookTable = [];
  List<List<double>> _whiteQueenTable = [];
  List<List<double>> _whiteKingMidGameTable = [];
  List<List<double>> _whiteKingEndgameTable = [];

  List<List<double>> _blackPawnTable = [];
  List<List<double>> _blackHorseTable = [];
  List<List<double>> _blackBishopTable = [];
  List<List<double>> _blackRookTable = [];
  List<List<double>> _blackQueenTable = [];
  List<List<double>> _blackKingMidGameTable = [];
  List<List<double>> _blackKingEndgameTable = [];
  bool _pieceCaptured = false;
  // Getter for pieceCaptured
  bool get pieceCaptured => _pieceCaptured;

  // Setter for pieceCaptured
  set pieceCaptured(bool capturedPiece) {
    _pieceCaptured = capturedPiece;
  }

  bool isWhite = false;
  List<List<int>> _board = [
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0],
  ];
  int _maxDepth = 1;
  late bool boardViewIsWhite;
  late ChessConfig chessConfig;
  late Function(List<List<int>>) _boardChangeCallback;
  Function(bool, CellPosition)? _pawnPromotion;
  late Function(GameOver) _gameOverCallback;
  final List<MovesLogModel> _moveLogs = [];

  // Method to capture a piece
  void capturePiece(String capturedPieceName) {
    capturedPieceHistory.add(capturedPieceName);
  }

  // List to store FEN and captured pieces at each move
  List<Map<String, dynamic>> fenHistoryWithCaptures = [];
  // List to track captured pieces
  List<int> capturedPieces = [];
  int _halfMoveClock = 0;
  int _fullMoveNumber = 0;

  ChessEngine(ChessConfig config,
      {required Function(List<List<int>>) boardChangeCallback,
      required Function(GameOver) gameOverCallback,
      Function(bool, CellPosition)? pawnPromotion}) {
    chessConfig = config;
    boardViewIsWhite = chessConfig.isPlayerAWhite;
    _initializeBoard();
    _initializePositionPointsTable();
    _initializeDifficultyMode();
    _boardChangeCallback = boardChangeCallback;
    _gameOverCallback = gameOverCallback;
    _pawnPromotion = pawnPromotion;
    _notifyBoardChangeCallback();
  }

  ///This Method will Initialize Difficult Mode.
  _initializeDifficultyMode() {
    if (chessConfig.difficulty == Difficulty.tooEasy) {
      _maxDepth = 2;
    } else if (chessConfig.difficulty == Difficulty.easy) {
      _maxDepth = 3;
    } else if (chessConfig.difficulty == Difficulty.medium) {
      _maxDepth = 4;
    } else if (chessConfig.difficulty == Difficulty.hard) {
      _maxDepth = 5;
    } else if (chessConfig.difficulty == Difficulty.asian) {
      _maxDepth = 6;
    }
  }

  ///This wi;; initialize the Position table.
  _initializePositionPointsTable() {
    if (chessConfig.isPlayerAWhite) {
      //If player is white PSQT is => Bottom=White, Top=Black
      // As PSQT designed From bottom to top perspective (Neither black nor white)
      _setBottomToTopPositionPoints();
    } else {
      //If Player is black Then we are just reversing the perspective
      _setTopToBottomPositionPoints();
    }
  }

  ///This will set bottom to Top position.
  _setBottomToTopPositionPoints() {
    _whitePawnTable = pawnSquareTable;
    _whiteHorseTable = horseSquareTable;
    _whiteBishopTable = bishopSquareTable;
    _whiteRookTable = rookSquareTable;
    _whiteQueenTable = queenSquareTable;
    _whiteKingMidGameTable = kingMidGameSquareTable;
    _whiteKingEndgameTable = kingEndGameSquareTable;

    _blackPawnTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(pawnSquareTable);
    _blackHorseTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(horseSquareTable);
    _blackBishopTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(bishopSquareTable);
    _blackRookTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(rookSquareTable);
    _blackQueenTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(queenSquareTable);
    _blackKingMidGameTable = ChessEngineHelpers.deepCopyAndReversePositionTable(
        kingMidGameSquareTable);
    _blackKingEndgameTable = ChessEngineHelpers.deepCopyAndReversePositionTable(
        kingEndGameSquareTable);
  }

  ///This will set top to bottom to position.
  _setTopToBottomPositionPoints() {
    _blackPawnTable = pawnSquareTable;
    _blackHorseTable = horseSquareTable;
    _blackBishopTable = bishopSquareTable;
    _blackRookTable = rookSquareTable;
    _blackQueenTable = queenSquareTable;
    _blackKingMidGameTable = kingMidGameSquareTable;
    _blackKingEndgameTable = kingEndGameSquareTable;

    _whitePawnTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(pawnSquareTable);
    _whiteHorseTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(horseSquareTable);
    _whiteBishopTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(bishopSquareTable);
    _whiteRookTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(rookSquareTable);
    _whiteQueenTable =
        ChessEngineHelpers.deepCopyAndReversePositionTable(queenSquareTable);
    _whiteKingMidGameTable = ChessEngineHelpers.deepCopyAndReversePositionTable(
        kingMidGameSquareTable);
    _whiteKingEndgameTable = ChessEngineHelpers.deepCopyAndReversePositionTable(
        kingEndGameSquareTable);
  }

  ///This method will return the half clock move for the board.
  int getHalfMoveClock() {
    return _halfMoveClock;
  }

  ///This method will return theFull move number for the board.
  int getFullMoveNumber() {
    return _fullMoveNumber;
  }

  ///This private methid is used to help notify the user about board change.
  void _notifyBoardChangeCallback() {
    _boardChangeCallback(_board);
  }

  ///This private methid is used to help notify the user about board gameover status.
  void _notifyGameOverStatus(GameOver status) {
    _gameOverCallback(status);
  }

  ///This method will return the board data in a 2D format.
  List<List<int>> getBoardData() {
    return _board;
  }

  ///This method will return the Move Logs Data.
  List<MovesLogModel> getMovesLogsData() {
    return _moveLogs;
  }

  ///This method will be used to return the best possible legal move.
  Future<MovesModel?> generateBestMove() async {
    await Future.delayed(const Duration(milliseconds: 10));
    double alpha = -double.infinity;
    double beta = double.infinity;
    MoveScore res = _minimaxWithMoveAlphaBetaPruning(
        _board, _maxDepth, alpha, beta, !chessConfig.isPlayerAWhite);

    return res.move;
  }

  ///This method will be used to return the random legal possible move.
  MovesModel? generateRandomMove() {
    List<CellPosition> allowedPeiceCoordinates = _getAllowedPieceCoordinates();
    allowedPeiceCoordinates.shuffle();
    for (var ele in allowedPeiceCoordinates) {
      List<CellPosition> validMove =
          getValidMovesOfPeiceByPosition(_board, ele);
      if (validMove.isEmpty) {
        continue;
      }
      validMove.shuffle();
      return MovesModel(
          currentPosition: CellPosition(row: ele.row, col: ele.col),
          targetPosition:
              CellPosition(row: validMove[0].row, col: validMove[0].col));
    }
    return null;
  }

  ///This private method is used for Internal purpose.
  List<CellPosition> _getAllowedPieceCoordinates() {
    List<CellPosition> allowedPiecesPosition = [];

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (chessConfig.isPlayerAWhite && _board[i][j] < 0) {
          allowedPiecesPosition.add(CellPosition(row: i, col: j));
        } else if (!chessConfig.isPlayerAWhite && _board[i][j] > 0) {
          allowedPiecesPosition.add(CellPosition(row: i, col: j));
        }
      }
    }

    return allowedPiecesPosition;
  }

  ///This private method is used for Internal purpose.

  List<MovesModel> _getWhitePossibleMove(List<List<int>> boardCopy) {
    List<MovesModel> movesList = [];
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (boardCopy[i][j] > emptyCellPower) {
          CellPosition currentPosition = CellPosition(row: i, col: j);
          List<CellPosition> possibleMove =
              getValidMovesOfPeiceByPosition(boardCopy, currentPosition);
          for (CellPosition targetPosition in possibleMove) {
            movesList.add(MovesModel(
                currentPosition: currentPosition,
                targetPosition: targetPosition));
          }
        }
      }
    }
    return movesList;
  }

  ///This private method is used for Internal purpose.
  List<MovesModel> _getBlackPossibleMove(List<List<int>> boardCopy) {
    List<MovesModel> movesList = [];
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (boardCopy[i][j] < emptyCellPower) {
          CellPosition currentPosition = CellPosition(row: i, col: j);
          List<CellPosition> possibleMove =
              getValidMovesOfPeiceByPosition(boardCopy, currentPosition);
          for (CellPosition targetPosition in possibleMove) {
            movesList.add(MovesModel(
                currentPosition: currentPosition,
                targetPosition: targetPosition));
          }
        }
      }
    }
    return movesList;
  }

  ///This method help to get the legal position of a piece in a board by its position.
  List<CellPosition> getValidMovesOfPeiceByPosition(
      List<List<int>> currBoard, CellPosition currentPosition) {
    var peice = currBoard[currentPosition.row][currentPosition.col];
    List<CellPosition> movesWithPossibleCheck = [];
    if (peice.abs() == horsePower) {
      movesWithPossibleCheck = ValidMoves.getValidHorseMoves(
          currBoard, currentPosition, boardViewIsWhite);
    }
    if (peice.abs() == rookPower) {
      movesWithPossibleCheck = ValidMoves.getValidRookMoves(
          currBoard, currentPosition, boardViewIsWhite);
    } else if (peice.abs() == bishopPower) {
      movesWithPossibleCheck = ValidMoves.getValidBishopMoves(
          currBoard, currentPosition, boardViewIsWhite);
    } else if (peice.abs() == queenPower) {
      movesWithPossibleCheck = ValidMoves.getValidQueenMoves(
          currBoard, currentPosition, boardViewIsWhite);
    } else if (peice.abs() == kingPower) {
      movesWithPossibleCheck = ValidMoves.getValidKingMove(
          currBoard, currentPosition, boardViewIsWhite, _moveLogs);
    } else if (peice.abs() == pawnPower) {
      movesWithPossibleCheck = ValidMoves.getValidPawnMove(
          currBoard, currentPosition, boardViewIsWhite);
    }

    return movesWithPossibleCheck;
  }

  ///This private method is used for Internal purpose.
  bool _isGameOverForThisBoard(List<List<int>> currBoard) {
    int kingCount = 0;
    for (List<int> ele in currBoard) {
      for (int item in ele) {
        if (item.abs() == kingPower) {
          if (kingCount == 1) {
            return false;
          }
          kingCount += 1;
        }
      }
    }
    return true;
  }

  ///This private method is used for Internal purpose.
  MoveScore _minimaxWithMoveAlphaBetaPruning(
      currBoard, depth, alpha, beta, maximizingPlayer) {
    if (depth == 0 || _isGameOverForThisBoard(currBoard)) {
      return MoveScore(move: null, score: _getScoreForBoard(currBoard));
    }

    if (maximizingPlayer) {
      double maxEval = -double.infinity;
      MovesModel? bestMove;
      List<MovesModel> whitePossibleMove = _getWhitePossibleMove(currBoard);
      for (MovesModel possibleMove in whitePossibleMove) {
        List<List<int>> boardCopy = ChessEngineHelpers.deepCopyBoard(currBoard);
        _movePieceForMinMax(boardCopy, possibleMove);
        double evaluation = _minimaxWithMoveAlphaBetaPruning(
                boardCopy, depth - 1, alpha, beta, false)
            .score;

        //Undoing the changes
        MovesModel undoingMove = MovesModel(
            currentPosition: possibleMove.targetPosition,
            targetPosition: possibleMove.currentPosition);
        _movePieceForMinMax(boardCopy, undoingMove);
        if (evaluation > maxEval) {
          maxEval = evaluation;
          bestMove = possibleMove;
        }
        alpha = max<double>(alpha, maxEval);
        if (beta <= alpha) {
          break; // Beta cut-off
        }
      }
      return MoveScore(move: bestMove, score: maxEval);
    } else {
      double minEval = double.infinity;
      MovesModel? bestMove;
      List<MovesModel> blackPossibleMove = _getBlackPossibleMove(currBoard);
      for (MovesModel possibleMove in blackPossibleMove) {
        List<List<int>> boardCopy = ChessEngineHelpers.deepCopyBoard(currBoard);
        _movePieceForMinMax(boardCopy, possibleMove);
        double evaluation = _minimaxWithMoveAlphaBetaPruning(
                boardCopy, depth - 1, alpha, beta, true)
            .score;
        //Undoing the changes
        MovesModel undoingMove = MovesModel(
            currentPosition: possibleMove.targetPosition,
            targetPosition: possibleMove.currentPosition);
        _movePieceForMinMax(boardCopy, undoingMove);
        if (evaluation < minEval) {
          minEval = evaluation;
          bestMove = possibleMove;
        }
        beta = min<double>(beta, minEval);
        if (beta <= alpha) {
          break; // Alpha cut-off
        }
      }
      return MoveScore(move: bestMove, score: minEval);
    }
  }

  ///This private method is used for Internal purpose.
  double _getScoreForBoard(List<List<int>> currBoard) {
    double overallScore = 0;

    // Material Advantage
    overallScore += _getMaterialScore(currBoard);
    // Piece Mobility and Positional Advantages
    overallScore += _getPositionalScore(currBoard);

    return overallScore;
  }

  ///This private method is used for Internal purpose.
  double _getMaterialScore(List<List<int>> currBoard) {
    double materialScore = 0;

    for (int row = 0; row < currBoard.length; row++) {
      for (int col = 0; col < currBoard.length; col++) {
        int piece = currBoard[row][col];
        switch (piece.abs()) {
          case pawnPower:
            materialScore +=
                pawnPower * (piece > 0 ? 1 : -1); // Assigning value to pawns
            break;
          case rookPower:
            materialScore +=
                rookPower * (piece > 0 ? 1 : -1); // Assigning value to rooks
            break;
          case horsePower:
            materialScore +=
                horsePower * (piece > 0 ? 1 : -1); // Assigning value to knights
            break;
          case bishopPower:
            materialScore += bishopPower *
                (piece > 0 ? 1 : -1); // Assigning value to bishops
            break;
          case queenPower:
            materialScore +=
                queenPower * (piece > 0 ? 1 : -1); // Assigning value to queens
            break;
          case kingPower:
            materialScore +=
                kingPower * (piece > 0 ? 1 : -1); // Assigning value to kings
            break;
          default:
            break;
        }
      }
    }

    return materialScore;
  }

  ///This private method is used for Internal purpose.
  double _getPositionalScore(List<List<int>> currBoard) {
    double positionalScore = 0;
    for (int row = 0; row < currBoard.length; row++) {
      for (int col = 0; col < currBoard.length; col++) {
        int piece = currBoard[row][col];
        if (piece == emptyCellPower) {
          continue;
        }
        bool isWhitePiece = piece > emptyCellPower;
        double pieceScore = 0;
        if (isWhitePiece) {
          //White Position points
          if (piece.abs() == pawnPower) {
            pieceScore = _whitePawnTable[row][col];
          } else if (piece.abs() == horsePower) {
            pieceScore = _whiteHorseTable[row][col];
          } else if (piece.abs() == bishopPower) {
            pieceScore = _whiteBishopTable[row][col];
          } else if (piece.abs() == rookPower) {
            pieceScore = _whiteRookTable[row][col];
          } else if (piece.abs() == kingPower) {
            if (_isEndGame(currBoard, true)) {
              pieceScore = _whiteKingEndgameTable[row][col];
            } else {
              pieceScore = _whiteKingMidGameTable[row][col];
            }
          } else if (piece.abs() == queenPower) {
            pieceScore = _whiteQueenTable[row][col];
          }
        } else {
          //Black Position points
          if (piece.abs() == pawnPower) {
            pieceScore = _blackPawnTable[row][col];
          } else if (piece.abs() == horsePower) {
            pieceScore = _blackHorseTable[row][col];
          } else if (piece.abs() == bishopPower) {
            pieceScore = _blackBishopTable[row][col];
          } else if (piece.abs() == rookPower) {
            pieceScore = _blackRookTable[row][col];
          } else if (piece.abs() == kingPower) {
            if (_isEndGame(currBoard, false)) {
              pieceScore = _blackKingEndgameTable[row][col];
            } else {
              pieceScore = _blackKingMidGameTable[row][col];
            }
          } else if (piece.abs() == queenPower) {
            pieceScore = _blackQueenTable[row][col];
          }
        }
        if (isWhitePiece) {
          positionalScore += pieceScore;
        } else {
          positionalScore -= pieceScore;
        }
      }
    }

    return positionalScore;
  }

  ///This private method is used for Internal purpose.
  bool _isEndGame(List<List<int>> curBoard, bool endGameCheckForWhite) {
    bool whiteQueenAlive = false;
    bool blackQueenAlive = false;
    int whiteMinorPieceCount = 0;
    int blackMinorPieceCount = 0;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        switch (curBoard[i][j]) {
          case queenPower:
            {
              whiteQueenAlive = true;
              break;
            }
          case const (-queenPower):
            {
              blackQueenAlive = true;
              break;
            }
          case const (bishopPower):
          case const (horsePower):
            {
              whiteMinorPieceCount += 1;
              break;
            }
          case const (-bishopPower):
          case const (-horsePower):
            {
              blackMinorPieceCount += 1;
              break;
            }
        }
        if (endGameCheckForWhite) {
          if (whiteQueenAlive && whiteMinorPieceCount > 2) {
            return false;
          }
        } else {
          if (blackQueenAlive && blackMinorPieceCount > 2) {
            return false;
          }
        }
      }
    }
    if ((!whiteQueenAlive && !blackQueenAlive)) {
      return true;
    }
    return false;
  }

  ///This private method is used for Internal purpose.
  void _movePieceForMinMax(List<List<int>> currBoard, MovesModel moves) {
    try {
      currBoard[moves.targetPosition.row][moves.targetPosition.col] =
          currBoard[moves.currentPosition.row][moves.currentPosition.col];
      currBoard[moves.currentPosition.row][moves.currentPosition.col] =
          emptyCellPower;
    } catch (ex) {
      // Do Nothing
    }
  }

  ///ThisMethod is used to set the Pawn promotion.
  setPawnPromotion(CellPosition targetPos, ChessPiece piece) {
    _setPawnPromotion(_board, targetPos, piece);
  }

  ///This private method is used for Internal purpose.
  _setPawnPromotion(
      List<List<int>> currBoard, CellPosition targetPos, ChessPiece piece) {
    if (piece != ChessPiece.king && piece != ChessPiece.pawn) {
      int isWhite = currBoard[targetPos.row][targetPos.col] > 0 ? 1 : -1;
      currBoard[targetPos.row][targetPos.col] =
          isWhite * chessPieceValue[piece]!;
      _notifyBoardChangeCallback();
    }
  }

  ///This private method is used for Internal purpose.
  _updateHalfMoveClock(MovesModel move) {
    if ((_board[move.currentPosition.row][move.currentPosition.col].abs() ==
            pawnPower) ||
        (_board[move.currentPosition.row][move.currentPosition.col] > 0 &&
            _board[move.targetPosition.row][move.targetPosition.col] < 0) ||
        (_board[move.currentPosition.row][move.currentPosition.col] < 0 &&
            _board[move.targetPosition.row][move.targetPosition.col] > 0)) {
      _halfMoveClock = 0;
    } else {
      _halfMoveClock += 1;
    }
  }

  ///This private method is used for Internal purpose.
  _updateFullMoveNumber(MovesModel move) {
    if (_board[move.currentPosition.row][move.currentPosition.col] < 0) {
      _fullMoveNumber += 1;
    }
  }

  /// This method use to move a piece in a board.
  void movePiece(MovesModel move, bool offline) {
    _updateHalfMoveClock(move);
    _updateFullMoveNumber(move);
    // Get the pieces on the board at the current and target positions
    int currentPiece =
        _board[move.currentPosition.row][move.currentPosition.col];
    int targetPiece = _board[move.targetPosition.row][move.targetPosition.col];
// Check if there is an opponent's piece at the target position (capture occurs)
    ChessData.lastPieceMoveColor = currentPiece > 0 ? "white" : "black";
    (currentPiece == 20000 && currentPiece > 0)
        ? ChessData.whiteKingPositions = {
            'row': move.targetPosition.row,
            'col': move.targetPosition.col
          }
        : ChessData.blackKingPositions = {
            'row': move.targetPosition.row,
            'col': move.targetPosition.col
          };

    bool isCapture = targetPiece != emptyCellPower &&
        (targetPiece > 0 != currentPiece > 0); // Pieces are of opposite sides
    OnlineChessData.caputuredPiece = "";
    if (isCapture) {
      pieceCaptured = true;
      print(
          'Capture occurred: Piece captured at position (${move.targetPosition.row}, ${move.targetPosition.col})');
      String capturedPieceName = getPieceName(targetPiece);
      OnlineChessData.caputuredPiece = capturedPieceName;
      print("Captured Piece name ${capturedPieceName}");
      // chessPieces.add({
      // "name": "Bishop",
      // "color": "white",
      // "image": "assets/ChessPiece/white_bishop.svg",
      // "count": 1
      // });
      capturedPieceHistory.add(capturedPieceName);
      saveFENAfterMove(targetPiece.abs());
      playMusic("audio/piece_kill.mp3");
      // Find the chess piece by name and update its count
      List<String> words = capturedPieceName.split(' '); // Splitting by space
      String pieceColor = words[0]; // "White"
      String pieceName = words[1]; // "Pawn"
      if (offline) {
        ChessData.fiftyMoveCount = 0;
        for (var piece in ChessData.chessPieces) {
          if (piece['name'] == pieceName && piece['color'] == pieceColor) {
            piece['count'] = piece['count'] + 1;
            if (pieceColor == "White") {
              ChessData.blackTotalNumber =
                  piece['num'] + ChessData.blackTotalNumber;
            } else {
              ChessData.whiteTotalNumber =
                  piece['num'] + ChessData.whiteTotalNumber;
            }
            break;
          }
        }
      }
    } else {
      capturedPieceHistory.add("");
      playMusic("audio/piece_move.mp3");
    }
    if (_canPromotePawn(_board, move)) {
      if (_pawnPromotion != null) {
        bool isWhitePiece =
            _board[move.currentPosition.row][move.currentPosition.col] > 0;
        // Future.delayed(const Duration(milliseconds: 300), () {
        //   _pawnPromotion!(isWhitePiece, move.targetPosition);
        // });
      }
    }

    if (_board[move.currentPosition.row][move.currentPosition.col].abs() ==
            kingPower &&
        ((move.currentPosition.col - move.targetPosition.col).abs() == 2)) {
      // perfom castling
      _performCastling(_board, move);
    } else {
      _board[move.targetPosition.row][move.targetPosition.col] =
          _board[move.currentPosition.row][move.currentPosition.col];
      _board[move.currentPosition.row][move.currentPosition.col] =
          emptyCellPower;
    }
    _moveLogs.add(MovesLogModel(
        move: move,
        piece: _board[move.targetPosition.row][move.targetPosition.col]));

    ChessData.onlineMoveLogs.add(MovesLogModel(
        move: move,
        piece: _board[move.targetPosition.row][move.targetPosition.col]));

    GameOver? gameOverStatus = _checkIfGameOver(
        _board[move.targetPosition.row][move.targetPosition.col] > 0);
    if (gameOverStatus != null) {
      _notifyGameOverStatus(gameOverStatus);
    }
    _notifyBoardChangeCallback();
  }

  ///This private method is used for Internal purpose.
  _performCastling(List<List<int>> currBoard, MovesModel move) {
    currBoard[move.targetPosition.row][move.targetPosition.col] =
        currBoard[move.currentPosition.row][move.currentPosition.col];
    currBoard[move.currentPosition.row][move.currentPosition.col] =
        emptyCellPower;

    // Castling with Right side Rook
    if (move.targetPosition.col > move.currentPosition.col) {
      currBoard[move.currentPosition.row][move.currentPosition.col + 1] =
          currBoard[move.currentPosition.row][7];
      currBoard[move.currentPosition.row][7] = emptyCellPower;
    }
    //Castling with left side rook
    else {
      currBoard[move.currentPosition.row][move.currentPosition.col - 1] =
          currBoard[move.currentPosition.row][0];
      currBoard[move.currentPosition.row][0] = emptyCellPower;
    }
  }

  ///This private method is used for Internal purpose.
  bool _canPromotePawn(List<List<int>> currBoard, MovesModel move) {
    if (currBoard[move.currentPosition.row][move.currentPosition.col] ==
            pawnPower &&
        (move.targetPosition.row == 0 || move.targetPosition.row == 7)) {
      return true;
    }
    return false;
  }

  ///This private method is used for Internal purpose.
  GameOver? _checkIfGameOver(bool islastMoveByWhite) {
    if (_halfMoveClock > 99) {
      return GameOver.draw;
    }
    bool onlyKingsInBoard = true;
    for (var rowEle in _board) {
      for (var ele in rowEle) {
        if (ele.abs() != kingPower) {
          onlyKingsInBoard = false;
          break;
        }
      }
    }
    if (onlyKingsInBoard) {
      return GameOver.draw;
    }
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (_board[i][j] != emptyCellPower) {
          if ((islastMoveByWhite && _board[i][j] < 0) ||
              (!islastMoveByWhite && _board[i][j] > 0)) {
            List<CellPosition> possible = getValidMovesOfPeiceByPosition(
                _board, CellPosition(row: i, col: j));
            if (possible.isNotEmpty) {
              return null;
            }
          }
        }
      }
    }
    if (islastMoveByWhite) {
      return GameOver.whiteWins;
    } else {
      return GameOver.blackWins;
    }
  }

  ///ThisMethod used to get the FEN string.
  String getFenString(bool isWhiteTurn) {
    List<String> fenArr = [];
    String piecePosFen = '';
    int emptyCount = 0;

    for (List<int> row in _board) {
      for (int square in row) {
        if (square == emptyCellPower) {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            piecePosFen += emptyCount.toString();
            emptyCount = 0;
          }
          if (square.abs() == pawnPower) {
            piecePosFen += square > 0 ? 'P' : 'p';
          } else if (square.abs() == kingPower) {
            piecePosFen += square > 0 ? 'K' : 'k';
          } else if (square.abs() == queenPower) {
            piecePosFen += square > 0 ? 'Q' : 'q';
          } else if (square.abs() == bishopPower) {
            piecePosFen += square > 0 ? 'B' : 'b';
          } else if (square.abs() == horsePower) {
            piecePosFen += square > 0 ? 'N' : 'n';
          } else if (square.abs() == rookPower) {
            piecePosFen += square > 0 ? 'R' : 'r';
          }
        }
      }
      if (emptyCount > 0) {
        piecePosFen += emptyCount.toString();
        emptyCount = 0;
      }
      piecePosFen += '/';
    }
    // Remove the trailing "/"
    piecePosFen = piecePosFen.substring(0, piecePosFen.length - 1);

    //Sending FEN string in White's Perspective
    if (chessConfig.isPlayerAWhite) {
      fenArr.add(piecePosFen);
    } else {
      fenArr.add(piecePosFen.split('').reversed.toList().join(''));
    }

    //Adding Turn
    fenArr.add(isWhiteTurn ? 'w' : 'b');

    //Adding Castling Possibilities
    String blackQueenSideRook = 'q';
    String blackKingSideRook = 'k';
    String whiteQueenSideRook = 'Q';
    String whiteKingSideRook = 'K';

    int topLeftRook = _board[0][0];
    int topRightRook = _board[0][7];
    int bottomLeftRook = _board[7][0];
    int bottomRightRook = _board[7][7];

    for (var log in _moveLogs) {
      if (log.piece == kingPower) {
        whiteQueenSideRook = '';
        whiteKingSideRook = '';
        break;
      }
      if (log.piece == -kingPower) {
        blackQueenSideRook = '';
        blackKingSideRook = '';
        break;
      }

      if ((_board[log.move.currentPosition.row][log.move.currentPosition.col] ==
              topLeftRook) ||
          (_board[log.move.targetPosition.row][log.move.targetPosition.col] ==
              topLeftRook)) {
        if (chessConfig.isPlayerAWhite) {
          blackQueenSideRook = '';
        } else {
          whiteQueenSideRook = '';
        }
      }
      if ((_board[log.move.currentPosition.row][log.move.currentPosition.col] ==
              topRightRook) ||
          (_board[log.move.targetPosition.row][log.move.targetPosition.col] ==
              topRightRook)) {
        if (chessConfig.isPlayerAWhite) {
          blackKingSideRook = '';
        } else {
          whiteKingSideRook = '';
        }
      }
      if ((_board[log.move.currentPosition.row][log.move.currentPosition.col] ==
              bottomLeftRook) ||
          (_board[log.move.targetPosition.row][log.move.targetPosition.col] ==
              bottomLeftRook)) {
        if (chessConfig.isPlayerAWhite) {
          whiteQueenSideRook = '';
        } else {
          blackKingSideRook = '';
        }
      }
      if ((_board[log.move.currentPosition.row][log.move.currentPosition.col] ==
              bottomRightRook) ||
          (_board[log.move.targetPosition.row][log.move.targetPosition.col] ==
              bottomRightRook)) {
        if (chessConfig.isPlayerAWhite) {
          whiteKingSideRook = '';
        } else {
          blackKingSideRook = '';
        }
      }
    }
    String castlingPossible = blackQueenSideRook +
        blackKingSideRook +
        whiteQueenSideRook +
        whiteKingSideRook;
    fenArr.add(castlingPossible.trim().isNotEmpty ? castlingPossible : '-');

    //Adding En pasant target
    fenArr.add('-');

    //Adding halfMoveClock
    fenArr.add(_halfMoveClock.toString());

    //Adding fullMoveNumber
    fenArr.add(_fullMoveNumber.toString());
    return fenArr.join(' ');
  }

  ///This private method is used for Internal purpose.
  int _getPowerFromFENChar(String char) {
    switch (char) {
      case 'P':
        return pawnPower;
      case 'p':
        return -pawnPower;
      case 'K':
        return kingPower;
      case 'k':
        return -kingPower;
      case 'Q':
        return queenPower;
      case 'q':
        return -queenPower;
      case 'B':
        return bishopPower;
      case 'b':
        return -bishopPower;
      case 'N':
        return horsePower;
      case 'n':
        return -horsePower;
      case 'R':
        return rookPower;
      case 'r':
        return -rookPower;
      default:
        return emptyCellPower;
    }
  }

  ///This method used to Set the FEN string.
  setFenString(String fenString) {
    List<String> fenParts = fenString.split(' ');

    // Parse piece positions component
    String piecePosFen = fenParts[0];
    List<String> rows = piecePosFen.split('/');
    //Setting in board
    for (int i = 0; i < 8; i++) {
      String row = rows[i];
      int file = 0;

      for (int j = 0; j < row.length; j++) {
        String char = row[j];

        if (RegExp(r'[1-8]').hasMatch(char)) {
          // Empty squares
          file += int.parse(char);
        } else {
          // Piece squares
          int power = _getPowerFromFENChar(char);
          _board[i][file] = power;
          file++;
        }
      }
    }

    if (!chessConfig.isPlayerAWhite) {
      // _board=ChessEngineHelpers.deepCopyAndReverseBoard(_board);
    }

    //2. Setting turn
    //Can leave

    //3. Setting castling details
    String castlingDetails = fenParts[2];
    if (!castlingDetails.contains('K')) {
      if (chessConfig.isPlayerAWhite) {
        _moveLogs.add(MovesLogModel(
            move: MovesModel(
                currentPosition: CellPosition(row: 7, col: 7),
                targetPosition: CellPosition(row: 0, col: 0)),
            piece: rookPower));
      } else {
        _moveLogs.add(MovesLogModel(
            move: MovesModel(
                currentPosition: CellPosition(row: 0, col: 7),
                targetPosition: CellPosition(row: 0, col: 0)),
            piece: rookPower));
      }
    }
    if (!castlingDetails.contains('k')) {
      if (chessConfig.isPlayerAWhite) {
        _moveLogs.add(MovesLogModel(
            move: MovesModel(
                currentPosition: CellPosition(row: 0, col: 7),
                targetPosition: CellPosition(row: 0, col: 0)),
            piece: -rookPower));
      } else {
        _moveLogs.add(MovesLogModel(
            move: MovesModel(
                currentPosition: CellPosition(row: 7, col: 7),
                targetPosition: CellPosition(row: 0, col: 0)),
            piece: -rookPower));
      }
    }
    if (!castlingDetails.contains('Q')) {
      if (chessConfig.isPlayerAWhite) {
        _moveLogs.add(MovesLogModel(
            move: MovesModel(
                currentPosition: CellPosition(row: 7, col: 0),
                targetPosition: CellPosition(row: 0, col: 0)),
            piece: rookPower));
      } else {
        _moveLogs.add(MovesLogModel(
            move: MovesModel(
                currentPosition: CellPosition(row: 0, col: 0),
                targetPosition: CellPosition(row: 0, col: 0)),
            piece: rookPower));
      }
    }
    if (!castlingDetails.contains('q')) {
      if (chessConfig.isPlayerAWhite) {
        _moveLogs.add(MovesLogModel(
            move: MovesModel(
                currentPosition: CellPosition(row: 0, col: 0),
                targetPosition: CellPosition(row: 0, col: 0)),
            piece: -rookPower));
      } else {
        _moveLogs.add(MovesLogModel(
            move: MovesModel(
                currentPosition: CellPosition(row: 7, col: 0),
                targetPosition: CellPosition(row: 0, col: 0)),
            piece: -rookPower));
      }
    }
    //4. En pasant
    //Leave
    //5. Setting halfMoveClock
    _halfMoveClock = int.tryParse(fenParts[4]) ?? 0;
    //6. Setting full Move Number
    _fullMoveNumber = int.tryParse(fenParts[5]) ?? 0;
  }

  ///This method is to validate the FEN string.
  bool isValidFEN(String fenString) {
    // Split the FEN string into its components
    List<String> parts = fenString.split(' ');

    // Ensure there are exactly 6 segments
    if (parts.length != 6) {
      return false;
    }

    // Validate each segment individually

    // 1. Piece placement
    if (!_isValidPiecePlacement(parts[0])) {
      return false;
    }

    // 2. Active color
    if (!_isValidActiveColor(parts[1])) {
      return false;
    }

    // 3. Castling availability
    if (!_isValidCastlingAvailability(parts[2])) {
      return false;
    }

    // 4. En passant target square
    if (!_isValidEnPassantSquare(parts[3])) {
      return false;
    }

    // 5. Halfmove clock
    if (!_isValidHalfmoveClock(parts[4])) {
      return false;
    }

    // 6. Fullmove number
    if (!_isValidFullmoveNumber(parts[5])) {
      return false;
    }

    // All segments are valid
    return true;
  }

  ///This private method is used for Internal purpose.
  bool _isValidPiecePlacement(String piecePlacement) {
    // Check if there are exactly 8 rows separated by '/'
    List<String> rows = piecePlacement.split('/');
    if (rows.length != 8) {
      return false;
    }

    // Check each row
    for (String row in rows) {
      // Validate each character in the row
      for (int i = 0; i < row.length; i++) {
        String char = row[i];
        // Check if the character represents a valid piece or empty square
        if (!(RegExp(r'[1-8]|[KQRBNPkqrbnp]').hasMatch(char))) {
          return false;
        }
      }
    }

    // All checks passed, the piece placement segment is valid
    return true;
  }

  ///This private method is used for Internal purpose.
  bool _isValidActiveColor(String activeColor) {
    // Implement validation logic for active color segment
    // Ensure it is either 'w' or 'b'
    return activeColor == 'w' || activeColor == 'b';
  }

  ///This private method is used for Internal purpose.
  bool _isValidCastlingAvailability(String castlingAvailability) {
    // Implement validation logic for castling availability segment
    // Ensure it consists of valid letters ('K', 'Q', 'k', 'q') or a hyphen '-'
    return RegExp(r'^(-|[KQkq]{0,4})$').hasMatch(castlingAvailability);
  }

  ///This private method is used for Internal purpose.
  bool _isValidEnPassantSquare(String enPassantSquare) {
    // Implement validation logic for en passant target square segment
    // Ensure it is a valid square (e.g., 'a3', 'h6') or a hyphen '-'
    return RegExp(r'^(-|[a-h][36])$').hasMatch(enPassantSquare);
  }

  ///This private method is used for Internal purpose.
  bool _isValidHalfmoveClock(String halfmoveClock) {
    // Implement validation logic for halfmove clock segment
    // Ensure it is a non-negative integer
    return int.tryParse(halfmoveClock) != null && int.parse(halfmoveClock) >= 0;
  }

  ///This private method is used for Internal purpose.
  bool _isValidFullmoveNumber(String fullmoveNumber) {
    // Implement validation logic for fullmove number segment
    // Ensure it is a positive integer
    return int.tryParse(fullmoveNumber) != null &&
        int.parse(fullmoveNumber) >= 0;
  }

  ///This private method is used for Internal purpose.
  ///This private method is used for Internal purpose.
  _initializeBoard() {
    if (chessConfig.fenString.isEmpty) {
      List<List<int>> chessBoard = [
        [
          -chessPieceValue[ChessPiece.rook]!,
          -chessPieceValue[ChessPiece.horse]!,
          -chessPieceValue[ChessPiece.bishop]!,
          -chessPieceValue[ChessPiece.queen]!,
          -chessPieceValue[ChessPiece.king]!,
          -chessPieceValue[ChessPiece.bishop]!,
          -chessPieceValue[ChessPiece.horse]!,
          -chessPieceValue[ChessPiece.rook]!,
        ],
        [
          -chessPieceValue[ChessPiece.pawn]!,
          -chessPieceValue[ChessPiece.pawn]!,
          -chessPieceValue[ChessPiece.pawn]!,
          -chessPieceValue[ChessPiece.pawn]!,
          -chessPieceValue[ChessPiece.pawn]!,
          -chessPieceValue[ChessPiece.pawn]!,
          -chessPieceValue[ChessPiece.pawn]!,
          -chessPieceValue[ChessPiece.pawn]!,
        ],
        [
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!
        ],
        [
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!
        ],
        [
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!
        ],
        [
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!,
          chessPieceValue[ChessPiece.emptyCell]!
        ],
        [
          chessPieceValue[ChessPiece.pawn]!,
          chessPieceValue[ChessPiece.pawn]!,
          chessPieceValue[ChessPiece.pawn]!,
          chessPieceValue[ChessPiece.pawn]!,
          chessPieceValue[ChessPiece.pawn]!,
          chessPieceValue[ChessPiece.pawn]!,
          chessPieceValue[ChessPiece.pawn]!,
          chessPieceValue[ChessPiece.pawn]!,
        ],
        [
          chessPieceValue[ChessPiece.rook]!,
          chessPieceValue[ChessPiece.horse]!,
          chessPieceValue[ChessPiece.bishop]!,
          chessPieceValue[ChessPiece.queen]!,
          chessPieceValue[ChessPiece.king]!,
          chessPieceValue[ChessPiece.bishop]!,
          chessPieceValue[ChessPiece.horse]!,
          chessPieceValue[ChessPiece.rook]!,
        ]
      ];
      if (!chessConfig.isPlayerAWhite) {
        for (int i = 0; i < 2; i++) {
          for (int j = 0; j < 8; j++) {
            chessBoard[i][j] = (-1 * chessBoard[i][j]);
          }
        }
        for (int i = 6; i < 8; i++) {
          for (int j = 0; j < 8; j++) {
            chessBoard[i][j] = (-1 * chessBoard[i][j]);
          }
        }
      }
      _board = chessBoard;
    } else {
      // Load FEN
      setFenString(chessConfig.fenString);
    }
  }

  Future<void> playMusic(String musicPath) async {
    // Use 'AssetSource' for playing from assets
    ChessData.unvalidMoves.clear();
    AudioPlayer _audioPlayer = AudioPlayer();
    await _audioPlayer.play(AssetSource(musicPath));
  }

  String getPieceName(int piece) {
    switch (piece.abs()) {
      case 100:
        return piece > 0 ? "White Pawn" : "Black Pawn";
      case 500:
        return piece > 0 ? "White Rook" : "Black Rook";
      case 320:
        return piece > 0 ? "White Horse" : "Black Horse";
      case 330:
        return piece > 0 ? "White Bishop" : "Black Bishop";
      case 900:
        return piece > 0 ? "White Queen" : "Black Queen";
      case 20000:
        return piece > 0 ? "White King" : "Black King";
      default:
        return "Unknown piece";
    }
  }

  // Simulate saving FEN and captured pieces after a move
  void saveFENAfterMove(int? capturedPiece) {
    String currentFEN = getFenString(true);
    if (capturedPiece != null) {
      capturedPieces.add(capturedPiece); // Add the captured piece to the list
    }
    fenHistoryWithCaptures.add({
      'fen': currentFEN,
      'capturedPieces':
          List.from(capturedPieces) // Store captured pieces so far
    });
    print("Saved FEN: $currentFEN with captured pieces: $capturedPieces");
  }

  // Simulate restoring the game from a FEN string and captured pieces
  void restoreFromFEN(int moveIndex) {
    if (moveIndex >= 0 && moveIndex < fenHistoryWithCaptures.length) {
      String selectedFEN = fenHistoryWithCaptures[moveIndex]['fen'];
      List<int> capturedPiecesAtMove =
          fenHistoryWithCaptures[moveIndex]['capturedPieces'];

      // loadPositionFromFEN(selectedFEN);  // Restore board state from FEN
      // restoreCapturedPieces(capturedPiecesAtMove);  // Restore captured pieces
    } else {
      print("Invalid move index");
    }
  }
}
