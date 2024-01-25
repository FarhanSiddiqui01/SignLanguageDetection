import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imagetoframe/controller/authcontroller.dart';
import 'package:imagetoframe/screens/conversationbot.dart';
import 'package:imagetoframe/screens/login.dart';
import 'package:imagetoframe/service/local_storage_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      Credentail? userCredentail = await _localStorageService.getCredentail();
      if (userCredentail == null) {
        navigateToLogin();
      } else {
        loginWithCredentails(userCredentail);
      }
    });
  }

  void loginWithCredentails(Credentail userCredentail) async {
    var result = await loginWithEmailPassword(
        userCredentail.email, userCredentail.password, ref);
    if (result != null) {
      navigateToConversation();
    } else {
      _localStorageService.removeCredentail();
      navigateToLogin();
    }
  }

  void navigateToLogin() {
    Timer(const Duration(milliseconds: 800), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    });
  }

  void navigateToConversation() {
    Timer(const Duration(milliseconds: 800), () {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const ConversationWithBot()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: FractionallySizedBox(
        widthFactor: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [iconShow(), title()],
        ),
      ),
    );
  }

  //Widgets

  Widget title() {
    return const Text(
      "Urdu Sign Language Detector",
      style: TextStyle(color: Colors.white, fontSize: 20),
    );
  }

  Widget iconShow() {
    return Icon(
      Icons.thumb_up_alt,
      color: Colors.white,
      size: 112.sp,
    );
  }
}
