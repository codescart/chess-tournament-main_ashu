// ignore_for_file: avoid_print

import 'package:chess_tournament/src/backend/chessuser_service.dart';
import 'package:chess_tournament/src/frontend/base_screen.dart';
import 'package:chess_tournament/src/frontend/common/base_button.dart';
import 'package:chess_tournament/src/frontend/common/base_input_field.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:sizer/sizer.dart';

class RegistrationScreen extends BasePageScreen {
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends BasePageScreenState<RegistrationScreen>
    with BaseScreen {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;

  final emailController = TextEditingController();
  final chessUsernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;
      Navigator.pushNamed(context, '/');
    });
  }

  @override
  String appBarTitle() {
    return "Register";
  }

  @override
  Widget body(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(2.w),
                    child: SizedBox(
                      width: 70.w,
                      child: BaseInputField(
                        numbersOnly: false,
                        placeholderText: 'Email',
                        textFieldController: emailController,
                        validatorCallback: (string) {},
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2.w),
                    child: SizedBox(
                      width: 70.w,
                      child: BaseInputField(
                        numbersOnly: false,
                        placeholderText: 'Chess.com Username',
                        textFieldController: chessUsernameController,
                        validatorCallback: (string) {},
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2.w),
                    child: SizedBox(
                      width: 70.w,
                      child: BaseInputField(
                        numbersOnly: false,
                        placeholderText: 'Password',
                        textFieldController: passwordController,
                        validatorCallback: (string) {},
                        valueVisible: false,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2.w),
                    child: SizedBox(
                      width: 70.w,
                      child: BaseInputField(
                        numbersOnly: false,
                        placeholderText: 'Confirm Password',
                        textFieldController: confirmPasswordController,
                        validatorCallback: (string) {
                          if (string == passwordController.text) {
                            return null;
                          }
                          return "Password doesn't match";
                        },
                        valueVisible: false,
                      ),
                    ),
                  ),
                  BaseButton(text: 'Register', callback: registerUser),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(2.w),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(2.w),
                    child: const Text("Already a member?"),
                  ),
                  ElevatedButton(
                    onPressed: (() =>
                        Navigator.pushNamed(context, "login_screen")),
                    child: const Text("Login here!"),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void registerUser() async {
    setState(() {
      showSpinner = true;
    });
    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      ChessUser user =
          await ChessUserService.createChessUser(chessUsernameController.text);

      user.userId = newUser.user!.uid;
      user.docId = (await ChessUserService.addUserToDB(user)).id;

      if (!mounted) return;
      Navigator.pushNamed(context, '/');
    } catch (e) {
      print(e);
    }
    setState(() {
      showSpinner = false;
    });
  }
}
