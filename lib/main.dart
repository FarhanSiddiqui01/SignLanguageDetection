import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:imagetoframe/screens/splashscreen.dart';

import 'firebase_options.dart';

const primaryColor = Color(0XFF121C7B);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );

  runApp(ScreenUtilInit(
      designSize: const Size(366, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return ProviderScope(
            child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Urdu Sign Language Detector',
          home: const SplashScreen(),
          theme: ThemeData(
              primarySwatch: MaterialColor(primaryColor.value, <int, Color>{
                50: primaryColor.withOpacity(0.1),
                100: primaryColor.withOpacity(0.2),
                200: primaryColor.withOpacity(0.3),
                300: primaryColor.withOpacity(0.4),
                400: primaryColor.withOpacity(0.5),
                500: primaryColor.withOpacity(0.6),
                600: primaryColor.withOpacity(0.7),
                700: primaryColor.withOpacity(0.8),
                800: primaryColor.withOpacity(0.9),
                900: primaryColor.withOpacity(1.0),
              }),
              primaryColor: const Color(0XFF121C7B)),
        ));
      }));
}
