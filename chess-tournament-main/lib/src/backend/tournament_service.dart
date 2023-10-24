// ignore_for_file: avoid_print

import 'dart:math';

import 'package:chess_tournament/src/backend/chessuser_service.dart';
import 'package:chess_tournament/src/backend/match_service.dart';
import 'package:chess_tournament/src/backend/tournament_settings_service.dart';
import 'package:chess_tournament/src/backend/tournament_stats_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum TournamentState {
  notStarted,
  started,
  finished,
}

class Tournament {
  String? docId;
  String? code;
  TournamentState? state;
  String? settings;
  ChessUser? owner;

  Tournament({
    required this.docId,
    required this.code,
    required this.state,
    required this.settings,
    required this.owner,
  });

  static Future<Tournament> fromJSON(
      Map<String, dynamic> snapshot, String docId) async {
    var code = snapshot["code"];
    var state = TournamentService.convertToTournamentState(snapshot["state"]);
    var settings = snapshot["settings"];
    var owner = await ChessUserService.getUserByDocId(snapshot["owner"]);
    return Tournament(
        docId: docId,
        code: code,
        state: state,
        settings: settings,
        owner: owner);
  }
}

class TournamentService {
  static Future<Tournament> getTournamentByCode(String tournamentCode) async {
    Tournament? tournament;
    try {
      var response =
          await FirebaseFirestore.instance.collection("tournaments").get();
      for (var tournaments in response.docs) {
        if (tournaments.data()["code"] == tournamentCode) {
          tournament =
              await Tournament.fromJSON(tournaments.data(), tournaments.id);
        }
      }
    } catch (error) {
      print(error);
    }
    return tournament!;
  }

  static Future<List<ChessUser>> getTournamentParticipants(
      String tournamentCode) async {
    List<ChessUser> participants = List.empty(growable: true);
    try {
      var firebaseResponse =
          await FirebaseFirestore.instance.collection('users').get();

      for (var user in firebaseResponse.docs) {
        participants.add(ChessUser.fromJSON(user.data(), user.id));
        participants
            .removeWhere((element) => element.tournamentCode != tournamentCode);
      }
    } catch (error) {
      print(error);
    }
    // for (var participant in participants) {
    //   var statsId = await createDefaultTournamentStats(participant);
    //   createUserTournamentStatsRelation(participant, statsId, tournamentCode);
    // }
    return participants;
  }

  static int generateCode() {
    return Random().nextInt(899999) + 100000;
  }

  static Future<bool> codeExistsInDB(String code) async {
    bool retVal = false;
    try {
      var firebaseResponse =
          await FirebaseFirestore.instance.collection('tournaments').get();
      for (var tournament in firebaseResponse.docs) {
        if (tournament.data()["code"].toString() == code) {
          retVal = true;
        }
      }
    } catch (error) {
      print(error);
    }
    return retVal;
  }

  static Future<String> createDefaultTournamentSettings() async {
    String? id;
    try {
      id = (await FirebaseFirestore.instance
              .collection('tournamentSettings')
              .add({
        "format": "roundRobin",
        "totalTime": 10,
        "increment": 1,
        "evenTimeSplit": true,
      }))
          .id;
    } catch (error) {
      print("createDefaultTournamentSettings$error");
    }

    return id!;
  }

  static Future<String> addTournament(ChessUser owner) async {
    int code = generateCode();
    while ((await codeExistsInDB(code.toString()))) {
      code = generateCode();
    }

    var settingsDocRef = await createDefaultTournamentSettings();
    try {
      FirebaseFirestore.instance.collection('tournaments').add({
        "code": code.toString(),
        "state": TournamentState.notStarted.index,
        "settings": settingsDocRef,
        "owner": owner.docId
      });
    } catch (error) {
      print("addTournament$error");
    }

    return code.toString();
  }

  static Future<String> createDefaultTournamentStats(ChessUser user) async {
    String? id;
    try {
      id = (await FirebaseFirestore.instance.collection('tournamentStats').add(
        {
          "userDocId": user.docId,
          "wins": 0,
          "draws": 0,
          "losses": 0,
          "points": 0,
        },
      ))
          .id;
    } catch (error) {
      print("createDefaultTournamentSettings$error");
    }

    return id!;
  }

  static Future<String> createUserTournamentStatsRelation(
      ChessUser user, String statsDocId, String tournamentCode) async {
    String? id;
    try {
      id = (await FirebaseFirestore.instance
              .collection('tournamentUserStats')
              .add({
        "userDocId": user.docId,
        "statsDocId": statsDocId,
        "tournamentCode": tournamentCode,
      }))
          .id;
    } catch (error) {
      print("createDefaultTournamentSettings$error");
    }

    return id!;
  }

  static Future<bool> addUserToTournament(User user, String code) async {
    var codeExists = await codeExistsInDB(code);

    if (!codeExists) {
      return false;
    }

    var chessUser = await ChessUserService.getChessUserByUserId(user.uid);
    if (chessUser == null) {
      throw "Could not find chess user with uuid: ${user.uid}";
    }
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(chessUser.docId)
          .update({"tournamentCode": code});
      var statsId = await createDefaultTournamentStats(chessUser);
      createUserTournamentStatsRelation(chessUser, statsId, code);
    } catch (error) {
      print("addUserToTournament$error");
    }
    return true;
  }

  static Future<bool> isTournamentOwner(
      ChessUser user, String tournamentCode) async {
    var retVal = false;
    try {
      var response =
          await FirebaseFirestore.instance.collection('tournaments').get();
      for (var tournament in response.docs) {
        if (tournament.data()["code"] == tournamentCode &&
            tournament.data()["owner"] == user.docId) {
          retVal = true;
        }
      }
    } catch (error) {
      print("isTournamentOwner$error");
    }

    return retVal;
  }

  static TournamentState convertToTournamentState(int number) {
    return TournamentState.values[number];
  }

  static Future<bool> isTournamentStarted(String tournamentCode) async {
    var retVal = false;
    try {
      var response =
          await FirebaseFirestore.instance.collection('tournaments').get();
      for (var tournament in response.docs) {
        if (tournament.data()["code"] == tournamentCode &&
            TournamentService.convertToTournamentState(
                    tournament.data()["state"]) ==
                TournamentState.started) {
          retVal = true;
        }
      }
    } catch (error) {
      print("isTournamentStarted$error");
    }

    return retVal;
  }

  static Future<void> startTournament(
      String tournamentCode, List<ChessUser> participants) async {
    var settings =
        await TournamentSettingsService.getTournamentSettings(tournamentCode);
    var participants =
        await TournamentService.getTournamentParticipants(tournamentCode);
    var matches = await TournamentService.generateRoundRobin(
        participants, settings, tournamentCode);

    await TournamentService.setTournamentMatches(matches);

    await FirebaseFirestore.instance
        .collection('tournaments')
        .get()
        .then((value) {
      for (var element in value.docs) {
        if (element['code'] == tournamentCode) {
          FirebaseFirestore.instance
              .collection('tournaments')
              .doc(element.id)
              .update({"state": TournamentState.started.index});
        }
      }
    });
  }

  static Future<List<ChessMatch>> generateRoundRobin(
      List<ChessUser> participants,
      TournamentSettings settings,
      String tournamentCode) async {
    List<ChessMatch> matches = List.empty(growable: true);

    for (int i = 0; i < participants.length; i++) {
      for (int j = i + 1; j < participants.length; j++) {
        ChessUser? white;
        ChessUser? black;
        if (Random().nextInt(10000) >= 5000) {
          white = participants[i];
          black = participants[j];
        } else {
          white = participants[j];
          black = participants[i];
        }
        double whiteTime = settings.totalTime! / 2;
        double blackTime = settings.totalTime! / 2;
        if (!settings.evenTimeSplit!) {
          //Call algorithm
        }
        matches.add(
          ChessMatch(
            tournamentCode: tournamentCode,
            white: white,
            black: black,
            whiteTime: whiteTime,
            blackTime: blackTime,
            result: ChessMatchResult.notStarted,
          ),
        );
      }
    }

    return matches;
  }

  static Future<void> setTournamentMatches(List<ChessMatch> matches) async {
    try {
      var response = await FirebaseFirestore.instance
          .collection('matches')
          .where('tournamentCode', isEqualTo: matches[0].tournamentCode)
          .get();
      for (var match in response.docs) {
        FirebaseFirestore.instance
            .runTransaction((Transaction myTransaction) async {
          myTransaction.delete(match.reference);
        });
      }
    } catch (error) {
      print("setTournamentMatches$error");
    }

    for (int i = 0; i < matches.length; i++) {
      try {
        FirebaseFirestore.instance.collection("matches").add({
          "tournamentCode": matches[i].tournamentCode,
          "white": matches[i].white!.docId,
          "black": matches[i].black!.docId,
          "whiteTime": matches[i].whiteTime,
          "blackTime": matches[i].blackTime,
          "result": matches[i].result!.index,
        });
      } catch (error) {
        print("setTournamentMatches$error");
      }
    }
  }

  static Future<List<ChessMatch>> getTournamentMatches(
      String tournamentCode) async {
    List<ChessMatch> matches = List.empty(growable: true);
    User? currentUser = FirebaseAuth.instance.currentUser;
    ChessUser currUser =
        (await ChessUserService.getChessUserByUserId(currentUser!.uid))!;
    try {
      var response = await FirebaseFirestore.instance
          .collection('matches')
          .where('tournamentCode', isEqualTo: tournamentCode)
          .get();
      for (var element in response.docs) {
        if (element["white"] == currUser.docId ||
            element["black"] == currUser.docId) {
          matches.add(await ChessMatch.fromJSON(element.data(), element.id));
        }
      }
    } catch (error) {
      print(error);
    }
    return matches;
  }

  static Future<void> deleteTournamentSettings(String id) async {
    var response =
        await FirebaseFirestore.instance.collection('tournamentSettings').get();
    for (var settings in response.docs) {
      if (settings.id == id) {
        FirebaseFirestore.instance
            .runTransaction((Transaction myTransaction) async {
          myTransaction.delete(settings.reference);
        });
      }
    }
  }

  static Future<void> deleteTournament(String tournamentCode) async {
    var codeExists = await codeExistsInDB(tournamentCode);

    if (!codeExists) {
      throw "";
    }
    try {
      var response =
          await FirebaseFirestore.instance.collection("tournaments").get();
      for (var tournament in response.docs) {
        if (tournament.data()["code"] == tournamentCode) {
          FirebaseFirestore.instance
              .runTransaction((Transaction myTransaction) async {
            myTransaction.delete(tournament.reference);
          });
          deleteTournamentSettings(tournament.data()["settings"]);
        }
      }
    } catch (error) {
      print("deleteTournament$error");
    }

    try {
      var response = await FirebaseFirestore.instance
          .collection('users')
          .where('tournamentCode', isEqualTo: tournamentCode)
          .get();
      for (var user in response.docs) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.id)
            .update({"tournamentCode": ""});
      }
    } catch (error) {
      print("deleteTournament$error");
    }
  }

  static Future<void> leaveTournament() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    try {
      var currUser =
          await ChessUserService.getChessUserByUserId(currentUser!.uid);
      var response = await FirebaseFirestore.instance.collection('users').get();
      for (var user in response.docs) {
        if (user.id == currUser!.docId) {
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.id)
              .update({"tournamentCode": ""});
        }
      }
    } catch (error) {
      print("leaveTournament$error");
    }
  }

  static Future<List<TournamentUserStats>> getLeaderBoard(
      String tournamentCode) async {
    List<TournamentUserStats> usersStats = List.empty(growable: true);
    var participants =
        await TournamentService.getTournamentParticipants(tournamentCode);
    for (var participant in participants) {
      var stats = await TournamentStatsService.getTournamentStats(participant);
      usersStats.add(TournamentUserStats(
          user: participant, stats: stats, tournamentCode: tournamentCode));
    }
    usersStats.sort(((a, b) => b.stats!.points!.compareTo(a.stats!.points!)));
    return usersStats;
  }

  static Future<void> resetTournament(String tournamentCode) async {
    var codeExists = await codeExistsInDB(tournamentCode);

    if (!codeExists) {
      throw "";
    }
    var response = await FirebaseFirestore.instance
        .collection('matches')
        .where('tournamentCode', isEqualTo: tournamentCode)
        .get();
    for (var match in response.docs) {
      FirebaseFirestore.instance
          .collection('matches')
          .doc(match.id)
          .update({"result": 0});
    }

    var response2 = await FirebaseFirestore.instance
        .collection('tournamentUserStats')
        .where('tournamentCode', isEqualTo: tournamentCode)
        .get();
    for (var tournamentUserStat in response2.docs) {
      FirebaseFirestore.instance
          .collection('tournamentStats')
          .doc(tournamentUserStat["statsDocId"])
          .update({"draws": 0, "losses": 0, "wins": 0, "points": 0});
    }
  }
}
