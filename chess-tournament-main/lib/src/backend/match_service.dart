import 'package:chess_tournament/src/backend/chessuser_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ChessMatchResult {
  notStarted,
  whiteWon,
  blackWon,
  draw,
}

class ChessMatch {
  String? docId;
  String? tournamentCode;
  ChessUser? white;
  ChessUser? black;

  double? whiteTime;
  double? blackTime;

  ChessMatchResult? result;

  ChessMatch({
    this.docId,
    required this.tournamentCode,
    required this.white,
    required this.black,
    required this.whiteTime,
    required this.blackTime,
    required this.result,
  });

  static Future<ChessMatch> fromJSON(
      Map<String, dynamic> snapshot, String id) async {
    var white = await ChessUserService.getUserByDocId(snapshot["white"]);
    var black = await ChessUserService.getUserByDocId(snapshot["black"]);
    var tournamentCode = snapshot["tournamentCode"];
    var whiteTime = snapshot["whiteTime"];
    var blackTime = snapshot["blackTime"];
    var result = ChessMatchService.convertToChessMatchState(snapshot["result"]);
    return ChessMatch(
        docId: id,
        tournamentCode: tournamentCode,
        white: white,
        black: black,
        whiteTime: whiteTime,
        blackTime: blackTime,
        result: result);
  }
}

class ChessMatchService {
  static ChessMatchResult convertToChessMatchState(int number) {
    return ChessMatchResult.values[number];
  }

  static String getStatsDocFieldName(ChessMatchResult result, bool isWhite) {
    if (result == ChessMatchResult.whiteWon) {
      if (isWhite) {
        return "wins";
      } else {
        return "losses";
      }
    } else if (result == ChessMatchResult.blackWon) {
      if (isWhite) {
        return "losses";
      } else {
        return "wins";
      }
    } else {
      return "draws";
    }
  }

  static Future<void> updateUserStats(
      ChessUser user, ChessMatchResult state, bool isWhite) async {
    var userStats = await FirebaseFirestore.instance
        .collection('tournamentUserStats')
        .where("userDocId", isEqualTo: user.docId)
        .get();
    var result = getStatsDocFieldName(state, isWhite);
    var pointsGained = 0;
    if (result == "wins") {
      pointsGained = 2;
    } else if (result == "draws") {
      pointsGained = 1;
    }
    await FirebaseFirestore.instance
        .collection("tournamentStats")
        .doc(userStats.docs[0].data()["statsDocId"])
        .update({
      result: FieldValue.increment(1),
      "points": FieldValue.increment(pointsGained)
    });
  }

  static Future<void> updateMatchResult(
      ChessMatch match, ChessMatchResult state) async {
    await FirebaseFirestore.instance
        .collection('matches')
        .doc(match.docId)
        .update({"result": state.index});
    await updateUserStats(match.white!, state, true);
    await updateUserStats(match.black!, state, false);
  }
}
