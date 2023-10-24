import 'package:chess_tournament/src/frontend/common/base_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../base_screen.dart';

class WelcomeScreen extends BasePageScreen {
  const WelcomeScreen({super.key});

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends BasePageScreenState<WelcomeScreen>
    with BaseScreen {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;
      Navigator.pushNamed(context, '/');
    });
  }

  @override
  String appBarTitle() {
    return "Welcome";
  }

  @override
  Widget body(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BaseButton(
              text: 'Log In',
              callback: () {
                Navigator.pushNamed(context, 'login_screen');
              },
            ),
            BaseButton(
                text: 'Register',
                callback: () {
                  Navigator.pushNamed(context, 'registration_screen');
                }),
          ]),
    );
  }
}
