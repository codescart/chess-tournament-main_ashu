// ignore_for_file: avoid_print

import 'package:chess_tournament/src/backend/chessuser_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TournamentStats {
  String? docId;
  String? userDocId;
  int? wins;
  int? draws;
  int? losses;
  int? points;

  TournamentStats({
    this.docId,
    required this.userDocId,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.points,
  });

  static TournamentStats fromJSON(Map<String, dynamic> snapshot, String id) {
    var wins = snapshot["wins"];
    var userDocId = snapshot["userDocId"];
    var draws = snapshot["draws"];
    var losses = snapshot["losses"];
    var points = snapshot["points"];

    return TournamentStats(
      docId: id,
      userDocId: userDocId,
      wins: wins,
      draws: draws,
      losses: losses,
      points: points,
    );
  }
}

class TournamentUserStats {
  String? docId;
  ChessUser? user;
  TournamentStats? stats;

  String? tournamentCode;

  TournamentUserStats({
    this.docId,
    required this.user,
    required this.stats,
    required this.tournamentCode,
  });

  static Future<TournamentUserStats> fromJSON(
      Map<String, dynamic> snapshot, String id) async {
    var user = await ChessUserService.getUserByDocId(snapshot["userDocId"]);
    var stats =
        await TournamentStatsService.getStatsByDocId(snapshot["statsDocId"]);
    var tournamentCode = snapshot["tournamentCode"];

    return TournamentUserStats(
      docId: id,
      user: user,
      stats: stats,
      tournamentCode: tournamentCode,
    );
  }
}

class TournamentStatsService {
  static Future<TournamentStats> getStatsByDocId(String id) async {
    var response = await FirebaseFirestore.instance
        .collection("tournamentStats")
        .doc(id)
        .get();
    return TournamentStats.fromJSON(response.data()!, response.id);
  }

  static Future<void> setTournamentStats(
      ChessUser user, TournamentStats stats) async {
    try {
      var response = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.docId)
          .get();
      FirebaseFirestore.instance
          .collection('tournamentStats')
          .doc(response.data()!["stats"])
          .update({
        "wins": stats.wins,
        "draws": stats.draws,
        "losses": stats.losses,
        "points": stats.points,
      });
    } catch (error) {
      print("setTournamentSettings$error");
    }
  }

  static Future<TournamentStats> getTournamentStats(ChessUser user) async {
    var stats = await FirebaseFirestore.instance
        .collection("tournamentStats")
        .where("userDocId", isEqualTo: user.docId)
        .get();
    return TournamentStats.fromJSON(stats.docs[0].data(), stats.docs[0].id);
  }
}
