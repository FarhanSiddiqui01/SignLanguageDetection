import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imagetoframe/controller/authcontroller.dart';
import 'package:imagetoframe/controller/loadingscreen.dart';
import 'package:imagetoframe/customWidgets/customtextfield.dart';
import 'package:imagetoframe/screens/conversationbot.dart';
import 'package:imagetoframe/screens/signup.dart';

import '../customWidgets/customshowdialogbox.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  void login() async {
    //login a user with his credentials
    String email = _email.text.trim();
    String pass = _password.text.trim();

    _email.clear();
    _password.clear();

    List<String> missingElements = Validity.isValidLoginForm(email, pass);
    if (missingElements.isEmpty) {
      var result = await loginWithEmailPassword(email, pass, ref);
      if (result != null) {
        navigateToConversation();
      } else {
        showDialogBox(DialogState.failure, "Invalid Credentails", null, null);
      }
    } else {
      showDialogBox(DialogState.warning, "Credentails not filled correctly",
          null, missingElements);
    }
  }

  void showDialogBox(DialogState dialogState, String text, Function? dothen,
      List<String>? missingElements) {
    showTheDialogBox(context, dialogState, text, dothen, missingElements);
  }

  void navigateToSignUp() {
    //onclick navigate to signUp form
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SignUpPage()));
  }

  void navigateToConversation() {
    //onclick navigate to model prompt form
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const ConversationWithBot()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFFDF9F9),
      body: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 1,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 140.h,
                  ),
                  loginHeading(),
                  SizedBox(
                    height: 80.h,
                  ),
                  CustomTextField(
                    controller: _email,
                    hintText: "Email",
                    outlineBorderSide:
                        const BorderSide(color: Color(0XFF252525)),
                  ),
                  SizedBox(
                    height: 50.h,
                  ),
                  CustomTextField(
                    controller: _password,
                    hintText: "Password",
                    outlineBorderSide:
                        const BorderSide(color: Color(0XFF252525)),
                    isPasswordField: true,
                  ),
                  SizedBox(
                    height: 61.h,
                  ),
                  loginButton(),
                  SizedBox(
                    height: 61.h,
                  ),
                  signUpText()
                ],
              ),
            ),
            Visibility(
                visible: ref.watch(authLoader), child: const LoadingScreen()),
          ],
        ),
      ),
    );
  }

  //Widgets

  //Sign up Text

  Widget signUpText() {
    return InkWell(
      onTap: navigateToSignUp,
      child: SizedBox(
        height: 20.h,
        width: 230.w,
        child: FittedBox(
          child: Text(
            "Don't have an account? Signup",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                decoration: TextDecoration.underline),
          ),
        ),
      ),
    );
  }

  //Login Button

  Widget loginButton() {
    return InkWell(
      onTap: login,
      child: Container(
        width: 220.w,
        height: 51.h,
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: const Center(
          child: Text(
            "Login",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }

  //Login Heading

  Widget loginHeading() {
    return SizedBox(
      width: 1.sw,
      height: 50.h,
      child: SizedBox(
        height: 50.h,
        width: 120.w,
        child: FittedBox(
          child: Text(
            "Login",
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
