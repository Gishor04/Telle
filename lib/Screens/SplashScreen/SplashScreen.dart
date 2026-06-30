// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:tellie/Helpers/Colors/Colors.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:tellie/Screens/Authentication/AuthenticationMain/SigninScreen.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: HexColor("#2D2E2E"),
      body: SafeArea(
          child: SingleChildScrollView(
              child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.05),
          Center(
              child: Text(
            "Tellie",
            style: TextStyle(
                fontFamily: 'lemon',
                fontSize: 40,
                fontWeight: FontWeight.w600,
                color: primarygreencolor),
          )),
          SizedBox(height: screenHeight * 0.07),
          Container(
            height: screenHeight * 0.35,
            width: screenWidth,
            child: Lottie.asset('assets/json/machine.json'),
          ),
          SizedBox(height: screenHeight * 0.04),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Let's Hear a",
                      style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: primarywhitecolor),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Stories",
                      style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: HexColor("#2ADB7F")),
                    )
                  ],
                ),
                Text(
                  "From You",
                  style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: primarywhitecolor),
                ),
                SizedBox(height: screenHeight * 0.04),
                Text(
                  "Share and enjoy your interesting stories with other peoples.",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: HexColor("#92FE9D")),
                ),
                SizedBox(height: screenHeight * 0.08),
                SwipeButton.expand(
                  thumb: Icon(
                    Icons.double_arrow_rounded,
                    color: Colors.white,
                  ),
                  child: Text(
                    "Swipe to Get Started",
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                  activeThumbColor: Colors.black,
                  activeTrackColor: HexColor("#14FF85"),
                  onSwipe: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                )
              ],
            ),
          )
        ],
      ))),
    );
  }
}
