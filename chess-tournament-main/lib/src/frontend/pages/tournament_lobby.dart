import 'dart:async';

import 'package:chess_tournament/src/backend/chessuser_service.dart';
import 'package:chess_tournament/src/backend/tournament_service.dart';
import 'package:chess_tournament/src/backend/tournament_settings_service.dart';
import 'package:chess_tournament/src/frontend/base_screen.dart';
import 'package:chess_tournament/src/frontend/common/base_button.dart';
import 'package:chess_tournament/src/frontend/pages/tournament_overview.dart';
import 'package:chess_tournament/src/frontend/pages/tournament_settings.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class TournamentLobbyScreen extends BasePageScreen {
  final String tournamentCode;
  final bool isOwner;
  final bool isStarted;

  const TournamentLobbyScreen({
    super.key,
    required this.tournamentCode,
    required this.isOwner,
    required this.isStarted,
  });

  @override
  TournamentLobbyScreenState createState() => TournamentLobbyScreenState();
}

class TournamentLobbyScreenState
    extends BasePageScreenState<TournamentLobbyScreen> with BaseScreen {
  Future<List<ChessUser>>? participants;
  Timer? fetchTimer;

  @override
  void initState() {
    super.initState();
    participants =
        TournamentService.getTournamentParticipants(widget.tournamentCode);
    // setUpTimedFetch();
  }

  @override
  void dispose() {
    super.dispose();
    fetchTimer?.cancel();
  }

  @override
  String appBarTitle() {
    return "Tournament Lobby";
  }

  //TODO: this probably wastes a lot of battery. Find a way to subscribe
  //to changes instead
  setUpTimedFetch() {
    fetchTimer = Timer.periodic(
      const Duration(milliseconds: 5000),
      (timer) {
        setState(
          () {
            participants = TournamentService.getTournamentParticipants(
                widget.tournamentCode);
          },
        );
      },
    );
  }

  void startTournament() async {
    //TODO start tournament
    TournamentService.startTournament(
        widget.tournamentCode, await participants!);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TournamentOverviewScreen(tournamentCode: widget.tournamentCode),
      ),
    );
  }

  void goToTournament() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TournamentOverviewScreen(tournamentCode: widget.tournamentCode),
      ),
    );
  }

  void openTournamentSettings() async {
    TournamentSettings settings =
        await TournamentSettingsService.getTournamentSettings(
            widget.tournamentCode);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TournamentSettingsScreen(
          tournamentCode: widget.tournamentCode,
          currentSettings: settings,
        ),
      ),
    );
  }

  void deleteTournament() {
    TournamentService.deleteTournament(widget.tournamentCode);
    Navigator.of(context).pop();
  }

  void leaveTournament() {
    TournamentService.leaveTournament();
    Navigator.of(context).pop();
  }

  void resetTournament() {
    TournamentService.resetTournament(widget.tournamentCode);
  }

  @override
  Widget body(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(2.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 2.h),
              child: SizedBox(
                width: 90.w,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Column(
                      children: [
                        Text(
                          "Tournament Code",
                          style: TextStyle(
                            fontSize: 20.sp,
                          ),
                        ),
                        Text(
                          widget.tournamentCode,
                          style: TextStyle(
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 90.w,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Text(
                    "Participants",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 1.h),
                child: participantList(context),
              ),
            ),
            if (widget.isStarted) ...{
              Padding(
                padding: const EdgeInsets.all(1),
                child: BaseButton(
                  callback: goToTournament,
                  text: "Go To Tournament",
                ),
              ),
              if (widget.isOwner) ...{
                Padding(
                  padding: const EdgeInsets.all(1),
                  child: BaseButton(
                    callback: resetTournament,
                    text: "Reset Tournament",
                  ),
                ),
              }
            } else if (widget.isOwner) ...{
              Padding(
                padding: const EdgeInsets.all(1),
                child: BaseButton(
                  callback: startTournament,
                  text: "Start",
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(1),
                child: BaseButton(
                  callback: openTournamentSettings,
                  text: "Tournament Settings",
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(1),
                child: BaseButton(
                  callback: deleteTournament,
                  text: "Delete Tournament",
                ),
              ),
            } else ...{
              Padding(
                padding: const EdgeInsets.all(1),
                child: BaseButton(
                  callback: leaveTournament,
                  text: "Leave Tournament",
                ),
              ),
            }
          ],
        ),
      ),
    );
  }

  Widget participantList(BuildContext context) {
    return FutureBuilder(
      future: participants,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return SizedBox(
            width: 90.w,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return participantCard(snapshot.data![index]);
              },
            ),
          );
        }
      },
    );
  }

  Widget participantCard(ChessUser participant) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: EdgeInsets.all(2.w),
            child: SizedBox(
              width: 10.w,
              height: 4.h,
              child: ChessUserService.getAvatarFromUrl(participant.avatarUrl!),
            ),
          ),
          SizedBox(
            width: 40.w,
            height: 4.h,
            child: Center(child: Text(participant.name!)),
          ),
          SizedBox(
            width: 12.w,
            height: 4.h,
            child: const Center(
              child: Text("Rating:"),
            ),
          ),
          SizedBox(
            width: 8.w,
            height: 4.h,
            child: Center(
              child: Text(participant.rating!),
            ),
          ),
        ],
      ),
    );
  }
}
