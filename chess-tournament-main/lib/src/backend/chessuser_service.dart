// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:jovial_svg/jovial_svg.dart';

class ChessUser {
  String? docId;
  String? userId;
  String? name;
  String? rating;
  String? tournamentCode;
  String? avatarUrl;

  ChessUser({
    this.docId,
    this.userId,
    required this.name,
    this.rating,
    this.tournamentCode,
    this.avatarUrl,
  });

  ChessUser.fromJSON(Map<String, dynamic> snapshot, String dId) {
    docId = dId;
    userId = snapshot["userId"];
    name = snapshot["name"];
    rating = snapshot["rating"];
    tournamentCode = snapshot["tournamentCode"];
    avatarUrl = snapshot["avatarUrl"];
  }
}

class ChessUserService {
  static Future<DocumentReference<Map<String, dynamic>>> addUserToDB(
      ChessUser user) async {
    return await FirebaseFirestore.instance.collection('users').add({
      "userId": user.userId,
      "name": user.name,
      "rating": user.rating,
      "tournamentCode": user.tournamentCode,
      "avatarUrl": user.avatarUrl
    });
  }

  static Future<ChessUser?> getUserByDocId(String docId) async {
    //TODO Maybe filter this serverside
    ChessUser? returnVal;
    try {
      var users = await FirebaseFirestore.instance.collection('users').get();
      for (var user in users.docs) {
        if (user.id == docId) {
          returnVal = ChessUser.fromJSON(user.data(), user.id);
        }
      }
    } catch (error) {
      print("getUserById$error");
    }
    return returnVal;
  }

  static Future<ChessUser?> getUserByName(String name) async {
    //TODO Maybe filter this serverside
    ChessUser? returnVal;
    try {
      var users = await FirebaseFirestore.instance.collection('users').get();

      for (var user in users.docs) {
        if (user.data()["name"] == name) {
          returnVal = ChessUser.fromJSON(user.data(), user.id);
        }
      }
    } catch (error) {
      print("getUserByName$error");
    }
    return returnVal;
  }

  static Future<ChessUser?> getChessUserByUserId(String userId) async {
    //TODO Maybe filter this serverside
    ChessUser? returnVal;
    try {
      var users = await FirebaseFirestore.instance.collection('users').get();

      for (var user in users.docs) {
        if (user.data()["userId"] == userId) {
          returnVal = ChessUser.fromJSON(user.data(), user.id);
        }
      }
    } catch (error) {
      print("getChessUserByUUID$error");
    }
    return returnVal;
  }

  static FutureOr<void> onError(Object object) {
    print(object);
  }

  static Future<http.Response> fetchFromApi(String url) {
    return http.get(Uri.parse(url));
  }

  static Future<ChessUser> createChessUser(String userName) async {
    var jsonProfile =
        await fetchFromApi("https://api.chess.com/pub/player/$userName");
    if (jsonProfile.statusCode == 200) {
      var jsonStats = await fetchFromApi(
          "https://api.chess.com/pub/player/$userName/stats");
      if (jsonStats.statusCode == 200) {
        try {
          var jsonS = jsonDecode(jsonStats.body);
          var jsonP = jsonDecode(jsonProfile.body);
          var avatarUrl = jsonP["avatar"];
          avatarUrl ??=
              "https://www.chess.com/bundles/web/images/user-image.007dad08.svg";

          ChessUser user = ChessUser(
              name: userName,
              rating: jsonS["chess_rapid"]["last"]["rating"].toString(),
              avatarUrl: avatarUrl,
              tournamentCode: "");
          return user;
        } catch (error) {
          rethrow;
        }
      } else {
        throw jsonDecode(jsonStats.body);
      }
    } else {
      throw jsonDecode(jsonProfile.body);
    }
  }

  static Widget getAvatarFromUrl(String url) {
    if (url.endsWith(".svg")) {
      return ScalableImageWidget.fromSISource(
          si: ScalableImageSource.fromSvgHttpUrl(Uri.parse(url)));
    } else {
      return Image.network(url);
    }
  }
}
