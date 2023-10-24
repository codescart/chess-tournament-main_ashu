// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class TournamentSettings {
  String? docId;
  String? format;
  int? increment;
  int? totalTime;
  bool? evenTimeSplit;

  TournamentSettings({
    this.docId,
    required this.format,
    required this.increment,
    required this.totalTime,
    required this.evenTimeSplit,
  });

  static Future<TournamentSettings> fromJSON(
      Map<String, dynamic> snapshot, String docId) async {
    var format = snapshot["format"];
    var increment = snapshot["increment"];
    var timePerMatch = snapshot["totalTime"];
    var evenTimeSplit = snapshot["evenTimeSplit"];
    return TournamentSettings(
      docId: docId,
      format: format,
      increment: increment,
      totalTime: timePerMatch,
      evenTimeSplit: evenTimeSplit,
    );
  }
}

class TournamentSettingsService {
  static Future<void> setTournamentSettings(
      String tournamentCode, TournamentSettings settings) async {
    try {
      var response = await FirebaseFirestore.instance
          .collection("tournaments")
          .where('code', isEqualTo: tournamentCode)
          .get();
      for (var tournament in response.docs) {
        FirebaseFirestore.instance
            .collection('tournamentSettings')
            .doc(tournament.data()["settings"])
            .update({
          "format": settings.format,
          "increment": settings.increment,
          "totalTime": settings.totalTime,
          "evenTimeSplit": settings.evenTimeSplit,
        });
      }
    } catch (error) {
      print("setTournamentSettings$error");
    }
  }

  static Future<TournamentSettings> getTournamentSettings(
      String tournamentCode) async {
    try {
      var instance = FirebaseFirestore.instance;
      var tournamentResponse = await instance
          .collection('tournaments')
          .where('code', isEqualTo: tournamentCode)
          .get();
      var tournamentSettingsResponse =
          await instance.collection('tournamentSettings').get();

      for (var tournament in tournamentResponse.docs) {
        var settingsId = tournament.data()["settings"].toString();

        for (var settings in tournamentSettingsResponse.docs) {
          if (settings.id == settingsId) {
            return await TournamentSettings.fromJSON(
                settings.data(), settings.id);
          }
        }
      }
    } catch (error) {
      print("getTournamentSettings$error");
    }
    throw "tournament not found";
  }
}
