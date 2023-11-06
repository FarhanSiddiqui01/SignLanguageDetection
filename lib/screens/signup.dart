import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imagetoframe/customWidgets/customshowdialogbox.dart';

import '../controller/authcontroller.dart';
import '../controller/loadingscreen.dart';
import '../customWidgets/customtextfield.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final TextEditingController _email = TextEditingController();

  final TextEditingController _name = TextEditingController();

  final TextEditingController _phoneNo = TextEditingController();
  final TextEditingController _confirmpass = TextEditingController();
  final TextEditingController _password = TextEditingController();

  void showDialogBox(DialogState dialogState, String text, Function? dothen,
      List<String>? missingElements) {
    showTheDialogBox(context, dialogState, text, dothen, missingElements);
  }

  void signup() async {
    //registering a new user
    String email = _email.text.trim();
    String name = _name.text.trim();
    String phoneNo = _phoneNo.text.trim();
    String pass = _password.text.trim();
    String confirmpass = _confirmpass.text.trim();
    List<String> missingElements =
        Validity.isValidSignupForm(email, pass, phoneNo, confirmpass, name);
    if (missingElements.isEmpty) {
      var result =
          await registerWithEmailPassword(email, pass, name, phoneNo, ref);
      if (result != null) {
        showDialogBox(DialogState.success, "Registered successfully", () {
          Navigator.pop(context);
        }, null);
      } else {
        showDialogBox(DialogState.failure, "Could Not Register", null, null);
      }
    } else {
      showDialogBox(DialogState.warning, "Form not filled correctly", null,
          missingElements);
    }
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
              child: SizedBox(
                width: 1.sw,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 100.h,
                    ),
                    createAccountHeading(),
                    SizedBox(
                      height: 51.h,
                    ),
                    CustomTextField(
                      controller: _email,
                      hintText: "Email",
                      outlineBorderSide:
                          const BorderSide(color: Color(0XFF252525)),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    CustomTextField(
                      controller: _name,
                      hintText: "Name",
                      outlineBorderSide:
                          const BorderSide(color: Color(0XFF252525)),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    CustomTextField(
                      controller: _phoneNo,
                      hintText: "Phone no.",
                      outlineBorderSide:
                          const BorderSide(color: Color(0XFF252525)),
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    CustomTextField(
                      controller: _password,
                      hintText: "Password",
                      outlineBorderSide:
                          const BorderSide(color: Color(0XFF252525)),
                      isPasswordField: true,
                    ),
                    SizedBox(
                      height: 30.h,
                    ),
                    CustomTextField(
                      controller: _confirmpass,
                      hintText: "Confirm Password",
                      outlineBorderSide:
                          const BorderSide(color: Color(0XFF252525)),
                      isPasswordField: true,
                    ),
                    SizedBox(
                      height: 51.h,
                    ),
                    signUpButton(),
                  ],
                ),
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

  //create Account Heading

  Widget createAccountHeading() {
    return SizedBox(
      height: 42.h,
      width: 290.w,
      child: FittedBox(
        child: Text(
          "Create Account",
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  ////Login Button

  Widget signUpButton() {
    return InkWell(
      onTap: signup,
      child: Container(
        width: 220.w,
        height: 51.h,
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: const Center(
          child: Text(
            "Signup",
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
