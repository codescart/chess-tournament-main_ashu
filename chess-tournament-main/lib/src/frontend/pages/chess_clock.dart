import 'dart:async';

import 'package:chess_tournament/src/backend/match_service.dart';
import 'package:chess_tournament/src/frontend/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChessClockScreen extends BasePageScreen {
  final ChessMatch currentMatch;

  const ChessClockScreen({
    super.key,
    required this.currentMatch,
  });

  @override
  State<ChessClockScreen> createState() => _ChessClockScreenState();
}

class _ChessClockScreenState extends BasePageScreenState<ChessClockScreen>
    with BaseScreen {
  Timer? timer;
  bool gameIsRunning = false;
  bool gameIsOver = false;
  bool timeRanOut = false;
  bool whitesTurn = true;

  late int whitesTimeInMilliSeconds;
  late int blacksTimeInMilliSeconds;

  late String whitesTime;
  late String blacksTime;

  @override
  void initState() {
    whitesTimeInMilliSeconds = widget.currentMatch.whiteTime!.toInt() * 1000;
    blacksTimeInMilliSeconds = widget.currentMatch.blackTime!.toInt() * 1000;
    whitesTime = clockFormat.format(DateTime.fromMillisecondsSinceEpoch(
      whitesTimeInMilliSeconds.toInt(),
    ));
    blacksTime = clockFormat.format(DateTime.fromMillisecondsSinceEpoch(
      blacksTimeInMilliSeconds.toInt(),
    ));
    timer = Timer.periodic(
      const Duration(milliseconds: 10),
      (Timer t) => {
        timerLogic(),
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  String appBarTitle() {
    return "Chess clock";
  }

  @override
  Widget body(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GestureDetector(
                    onTap: blackSwitchedTurns,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.black,
                      ),
                      child: Center(
                        child: Text(
                          blacksTime.toString(),
                          style: const TextStyle(
                            fontSize: 100,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: ElevatedButton(
                      onPressed: onPauseButtonPressed,
                      child: const Icon(Icons.pause),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: ElevatedButton(
                      onPressed: onPlayButtonPressed,
                      child: const Icon(Icons.play_arrow),
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: ElevatedButton(
                      onPressed: onStopButtonPressed,
                      child: const Icon(Icons.stop),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GestureDetector(
                    onTap: whiteSwitchedTurns,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey,
                      ),
                      child: Center(
                        child: Text(
                          whitesTime.toString(),
                          style: const TextStyle(
                            fontSize: 100,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (gameIsOver) showGameOverDialog(),
        ],
      ),
    );
  }

  void whiteSwitchedTurns() {
    if (gameIsRunning && whitesTurn) whitesTurn = false;
  }

  void blackSwitchedTurns() {
    if (gameIsRunning && !whitesTurn) whitesTurn = true;
  }

  void onPlayButtonPressed() {
    gameIsRunning = true;
  }

  void onPauseButtonPressed() {
    gameIsRunning = false;
  }

  void onStopButtonPressed() {
    gameIsRunning = false;
    matchStopped();
  }

  var clockFormat = DateFormat('mm:ss');

  void timerLogic() {
    if (gameIsRunning) {
      if (whitesTurn) {
        whitesTimeInMilliSeconds -= 10;
        setState(() {
          whitesTime = checkTimeAndReturnFormatted(whitesTimeInMilliSeconds);
        });
      } else {
        blacksTimeInMilliSeconds -= 10;
        setState(() {
          blacksTime = checkTimeAndReturnFormatted(blacksTimeInMilliSeconds);
        });
      }
    }
  }

  String checkTimeAndReturnFormatted(int timeInMilliseconds) {
    if (timeInMilliseconds <= 0) {
      timeRanOut = true;
      timer?.cancel();
      matchStopped();
    }
    return clockFormat.format(
      DateTime.fromMillisecondsSinceEpoch(
        timeInMilliseconds.toInt(),
      ),
    );
  }

  void matchStopped() {
    setState(() {
      gameIsOver = true;
    });
    if (timeRanOut) {
      if (whitesTimeInMilliSeconds <= 0) {
        ChessMatchService.updateMatchResult(
            widget.currentMatch, ChessMatchResult.blackWon);
      } else {
        ChessMatchService.updateMatchResult(
            widget.currentMatch, ChessMatchResult.whiteWon);
      }
    }
  }

  Widget showGameOverDialog() {
    String dialogText;
    if (timeRanOut) {
      if (whitesTimeInMilliSeconds <= 0) {
        dialogText = "Black won on time!";
      } else {
        dialogText = "White won on time!";
      }
    } else {
      dialogText = "Who won?";
    }
    return Positioned(
      child: AlertDialog(
        title: const Center(
          child: Text("Game Over"),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(dialogText),
            )
          ],
        ),
        actions: [
          if (!timeRanOut) ...{
            ElevatedButton(
              onPressed: () {
                ChessMatchService.updateMatchResult(
                    widget.currentMatch, ChessMatchResult.whiteWon);
                Navigator.of(context).pop();
              },
              child: const Text('White Won'),
            ),
            ElevatedButton(
              onPressed: () {
                ChessMatchService.updateMatchResult(
                    widget.currentMatch, ChessMatchResult.draw);
                Navigator.of(context).pop();
              },
              child: const Text('Draw'),
            ),
            ElevatedButton(
              onPressed: () {
                ChessMatchService.updateMatchResult(
                    widget.currentMatch, ChessMatchResult.blackWon);
                Navigator.of(context).pop();
              },
              child: const Text('Black Won'),
            ),
          } else ...{
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Continue'),
              ),
            ),
          }
        ],
      ),
    );
  }
}
