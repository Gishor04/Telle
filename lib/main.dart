// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tellie/Screens/Authentication/AuthenticationMain/SigninScreen.dart';
import 'package:tellie/Screens/BottomNavigationBar/BottomNavigation.dart';
import 'package:tellie/Screens/SplashScreen/SplashScreen.dart';

import 'Helpers/Colors/Colors.dart';
import 'Helpers/Constants/TextStyle/Textstyle.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // HttpOverrides (dev SSL bypass) and orientation lock only work on native.
  // On Flutter Web the browser owns TLS and orientation — calling these APIs
  // on web triggers dart:io UnsupportedError and DOM init races.
  if (!kIsWeb) {
    HttpOverrides.global = MyHttpOverrides();
    await SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tellie',
      home: CheckAuthStatus(),
    );
  }
}

class CheckAuthStatus extends StatefulWidget {
  @override
  _CheckAuthStatusState createState() => _CheckAuthStatusState();
}

class _CheckAuthStatusState extends State<CheckAuthStatus> {
  @override
  void initState() {
    super.initState();
    // Defer navigation until after the first frame so the widget tree is
    // fully mounted — prevents context-not-ready errors on web.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) checkAuthStatus();
    });
  }

  void checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool showSplash = prefs.getBool('showSplash') ?? true;

    if (showSplash) {
      PrivacyPolicy.showAlertDialog(context);
      prefs.setBool('showSplash', false);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SplashScreen()));
    } else {
      String? token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BottomNavigationScreen(pageno: 2)));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// Bypasses bad SSL certs in development — native only, never runs on web.
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class PrivacyPolicy {
  static showAlertDialog(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    AlertDialog alert = AlertDialog(
      backgroundColor: HexColor("#F3FFF1"),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title:
          Center(child: Image(image: AssetImage("assets/images/newlogo1.png"))),
      content: Container(
        height: screenHeight * 0.25,
        width: screenWidth * 0.3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Disclaimer", style: authheadingstyle),
            SizedBox(height: screenHeight * 0.025),
            Text(
              "This application is released as a trial version for testing purpose",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              "This application might contain some faults as it is a testing version.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            )
          ],
        ),
      ),
      actions: [],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
