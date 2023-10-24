import 'package:chess_tournament/src/backend/match_service.dart';
import 'package:chess_tournament/src/backend/tournament_service.dart';
import 'package:chess_tournament/src/backend/tournament_stats_service.dart';
import 'package:chess_tournament/src/frontend/base_screen.dart';
import 'package:chess_tournament/src/frontend/pages/chess_clock.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../backend/chessuser_service.dart';

class TournamentOverviewScreen extends BasePageScreen {
  final String tournamentCode;

  const TournamentOverviewScreen({
    super.key,
    required this.tournamentCode,
  });

  @override
  State<TournamentOverviewScreen> createState() =>
      _TournamentOverviewScreenState();
}

class _TournamentOverviewScreenState
    extends BasePageScreenState<TournamentOverviewScreen> with BaseScreen {
  Future<List<ChessMatch>>? matches;

  @override
  void initState() {
    super.initState();
    matches = TournamentService.getTournamentMatches(widget.tournamentCode);
  }

  @override
  String appBarTitle() {
    return "Tournament Overview";
  }

  @override
  Widget body(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: minimizedLeaderBoard(),
            ),
          ),
          Expanded(
            flex: 7,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 1.h),
              child: matchesToPlay(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget minimizedLeaderBoard() {
    Future<List<TournamentUserStats>> leaderBoard =
        TournamentService.getLeaderBoard(widget.tournamentCode);
    return FutureBuilder(
      future: leaderBoard,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var index = 0;
          return ListView(
            shrinkWrap: true,
            children: snapshot.data!.map((participant) {
              index++;
              return Center(
                child: SizedBox(
                  width: 400,
                  height: 60,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: leaderBoardCard(participant, index),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget leaderBoardCard(
      TournamentUserStats tournamentUserStats, int placement) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$placement."),
        Text(tournamentUserStats.user!.name!),
        Text("W: ${tournamentUserStats.stats!.wins!}"),
        Text("D: ${tournamentUserStats.stats!.draws!}"),
        Text("L: ${tournamentUserStats.stats!.losses!}"),
        Text("P: ${tournamentUserStats.stats!.points!}"),
      ],
    );
  }

  Widget matchesToPlay(BuildContext context) {
    return FutureBuilder(
      future: matches,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return SizedBox(
            width: 80.w,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return matchCard(snapshot.data![index]);
              },
            ),
          );
        }
      },
    );
  }

  Widget matchCard(ChessMatch match) {
    Future<ChessUser?> currentUser = ChessUserService.getChessUserByUserId(
        FirebaseAuth.instance.currentUser!.uid);
    return FutureBuilder(
        future: currentUser,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 10.w,
                            height: 4.h,
                            child: ChessUserService.getAvatarFromUrl(
                                match.white!.avatarUrl!),
                          ),
                          Text(
                            match.white!.name!,
                            style: TextStyle(
                              fontSize: 9.sp,
                            ),
                          ),
                          Text(
                            "Rating: ${match.white!.rating}",
                            style: TextStyle(
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(.5.w),
                          child: Text(
                            "VS",
                            style: TextStyle(
                              fontSize: 9.sp,
                            ),
                          ),
                        ),
                        if (match.result == ChessMatchResult.notStarted) ...{
                          ElevatedButton(
                            onPressed: () => startMatch(match),
                            child: Text(
                              "Start",
                              style: TextStyle(
                                fontSize: 9.sp,
                              ),
                            ),
                          ),
                        } else if (match.result == ChessMatchResult.draw) ...{
                          drawWidget(),
                        } else if (match.white!.docId ==
                            snapshot.data!.docId) ...{
                          if (match.result == ChessMatchResult.whiteWon) ...{
                            winWidget(),
                          } else ...{
                            loseWidget(),
                          }
                        } else ...{
                          if (match.result == ChessMatchResult.whiteWon) ...{
                            loseWidget(),
                          } else ...{
                            winWidget(),
                          }
                        }
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 10.w,
                            height: 4.h,
                            child: ChessUserService.getAvatarFromUrl(
                                match.black!.avatarUrl!),
                          ),
                          Text(
                            match.black!.name!,
                            style: TextStyle(
                              fontSize: 9.sp,
                            ),
                          ),
                          Text(
                            "Rating: ${match.black!.rating}",
                            style: TextStyle(
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget drawWidget() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.all(Radius.circular(1.w))),
      child: Padding(
        padding: EdgeInsets.all(1.w),
        child: Text(
          "Draw",
          style: TextStyle(
            fontSize: 9.sp,
          ),
        ),
      ),
    );
  }

  Widget winWidget() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green,
          ),
          borderRadius: BorderRadius.all(Radius.circular(1.w))),
      child: Padding(
        padding: EdgeInsets.all(1.w),
        child: Text(
          "Win",
          style: TextStyle(
            fontSize: 9.sp,
          ),
        ),
      ),
    );
  }

  Widget loseWidget() {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.all(Radius.circular(1.w))),
      child: Padding(
        padding: EdgeInsets.all(1.w),
        child: Text(
          "Lose",
          style: TextStyle(
            fontSize: 9.sp,
          ),
        ),
      ),
    );
  }

  void startMatch(ChessMatch match) {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => ChessClockScreen(currentMatch: match)))
        .then((value) {
      matches = TournamentService.getTournamentMatches(widget.tournamentCode);
      setState(() {});
    });
  }
}
