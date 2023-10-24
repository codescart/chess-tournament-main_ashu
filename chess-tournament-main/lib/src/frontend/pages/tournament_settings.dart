import 'package:chess_tournament/src/backend/tournament_settings_service.dart';
import 'package:chess_tournament/src/frontend/common/base_button.dart';
import 'package:chess_tournament/src/frontend/common/base_input_increment.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../base_screen.dart';

class TournamentSettingsScreen extends BasePageScreen {
  final String tournamentCode;
  final TournamentSettings currentSettings;

  const TournamentSettingsScreen({
    super.key,
    required this.tournamentCode,
    required this.currentSettings,
  });

  @override
  TournamentSettingsScreenState createState() =>
      TournamentSettingsScreenState();
}

class TournamentSettingsScreenState
    extends BasePageScreenState<TournamentSettingsScreen> with BaseScreen {
  int gameTime = 0;
  int gameTimeMinutes = 0;
  int gameTimeSeconds = 0;
  int incrementTime = 0;
  int incrementTimeMinutes = 0;
  int incrementTimeSeconds = 0;
  String format = '';
  bool evenTimeSplit = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    format = widget.currentSettings.format!;

    gameTime = widget.currentSettings.totalTime!;
    gameTimeMinutes = (gameTime / 60).floor();
    gameTimeSeconds = gameTime - gameTimeMinutes * 60;

    incrementTime = widget.currentSettings.increment!;
    incrementTimeMinutes = (incrementTime / 60).floor();
    incrementTimeSeconds = incrementTime - incrementTimeMinutes * 60;

    evenTimeSplit = widget.currentSettings.evenTimeSplit!;
  }

  @override
  String appBarTitle() {
    return "Tournament Settings";
  }

  //TODO: fetch format from db
  var items = [
    'Round Robin',
    'Knockout',
    'Teams',
  ];

  //TODO: apply settings to db row

  @override
  Widget body(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600.0;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: isMobile ? 35.w : 20.w,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Text(
                    "Format",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 65.w,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: DropdownButton(
                    isExpanded: true,
                    // Initial Value
                    value: format,

                    // Down Arrow Icon
                    icon: const Icon(Icons.keyboard_arrow_down),

                    // Array list of items
                    items: items.map<DropdownMenuItem<String>>((String item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        format = newValue!;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 35.w,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Text(
                    "Total game time",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 65.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 25.h,
                      child: BaseInputIncrement(
                        onChanged: onGameTimeMinuteCounterChanged,
                        maxValue: 59,
                        minValue: 1,
                        startValue: gameTimeMinutes,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, .5.h),
                      child: Text(
                        ":",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25.h,
                      child: BaseInputIncrement(
                        onChanged: onGameTimeSecondCounterChanged,
                        maxValue: 59,
                        minValue: 0,
                        startValue: gameTimeSeconds,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 35.w,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Text(
                    "Increment",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 65.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 25.h,
                      child: BaseInputIncrement(
                        onChanged: onIncrementMinuteCounterChanged,
                        maxValue: 59,
                        minValue: 0,
                        startValue: incrementTimeMinutes,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, .5.h),
                      child: Text(
                        ":",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25.h,
                      child: BaseInputIncrement(
                        onChanged: onIncrementSecondCounterChanged,
                        maxValue: 59,
                        minValue: 0,
                        startValue: incrementTimeSeconds,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Row(
            //TODO: detta vart sisådär
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: isMobile ? 35.w : 20.w,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Text(
                    "Split time evenly",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 65.w,
                child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Switch(
                      value: evenTimeSplit,
                      onChanged: (value) {
                        setState(() {
                          evenTimeSplit = value;
                        });
                      },
                    )),
              ),
            ],
          ),
          BaseButton(
            text: 'Apply',
            callback: onApply,
          ),
        ],
      ),
    );
  }

  void onIncrementMinuteCounterChanged(int value) {
    incrementTimeMinutes = value;
    incrementTime = incrementTimeSeconds + incrementTimeMinutes * 60;
  }

  void onIncrementSecondCounterChanged(int value) {
    incrementTimeSeconds = value;
    incrementTime = incrementTimeSeconds + incrementTimeMinutes * 60;
  }

  void onGameTimeMinuteCounterChanged(int value) {
    gameTimeMinutes = value;
    gameTime = gameTimeSeconds + gameTimeMinutes * 60;
  }

  void onGameTimeSecondCounterChanged(int value) {
    gameTimeSeconds = value;
    gameTime = gameTimeSeconds + gameTimeMinutes * 60;
  }

  void onApply() {
    TournamentSettingsService.setTournamentSettings(
        widget.tournamentCode,
        TournamentSettings(
          format: format,
          increment: incrementTime,
          totalTime: gameTime,
          evenTimeSplit: evenTimeSplit,
        ));
    Navigator.pop(context);
  }
}
