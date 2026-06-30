// ignore_for_file: prefer_const_constructors, unused_local_variable, sort_child_properties_last, use_build_context_synchronously, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, unused_import

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tellie/API/ApiService.dart';
import 'package:tellie/Helpers/Colors/Colors.dart';
import 'package:tellie/Helpers/Constants/Loader/Loader.dart';
import 'package:tellie/Helpers/Constants/TextStyle/Textstyle.dart';
import 'package:tellie/Screens/Authentication/AuthenticationMain/SignUpScreen.dart';
import 'package:tellie/Screens/BottomNavigationBar/BottomNavigation.dart';
import '../Authentication-Reusable/Login-reusable.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController loginemailcontroller = TextEditingController();
  TextEditingController loginpasswordcontroller = TextEditingController();
  bool showPassword = true;
  bool _isLoading = false;
  String? bodyError;

  void obscurepsw() {
    setState(() => showPassword = !showPassword);
  }

  void navigation() {}

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Sign In", style: authheadingstyle),
                    SizedBox(height: screenHeight * 0.01),
                    Text("We are happy to see you here!", style: authsubheadingstyle),
                    SizedBox(height: screenHeight * 0.05),
                    Container(
                      height: screenHeight * 0.28,
                      width: screenWidth,
                      child: Lottie.asset('assets/json/book.json'),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    logintextform(loginemailcontroller),
                    SizedBox(height: screenHeight * 0.03),
                    textformpassword(loginpasswordcontroller, obscurepsw, showPassword),
                    SizedBox(height: screenHeight * 0.000002),
                    bodyError != null
                        ? Text(bodyError.toString(), style: TextStyle(color: Colors.red))
                        : SizedBox(),
                    SizedBox(height: screenHeight * 0.000001),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                          onPressed: () { navigation(); },
                          child: Text("Forgot Password ?", style: authcommonnavigationtextcolor)),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    _isLoading
                        ? loader
                        : Container(
                            height: screenHeight * 0.07,
                            width: screenWidth * 0.9,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            child: ElevatedButton(
                              child: Text("Login", style: buttontextstyle),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HexColor("#2ADB7F"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                loginUser(loginemailcontroller.text, loginpasswordcontroller.text);
                              },
                            ),
                          ),
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't Have an Account ", style: authcommonnavigationtextcolor),
                        SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) => SignUpScreen()),
                            );
                          },
                          child: Text(
                            "REGISTER",
                            style: TextStyle(
                                color: HexColor("#2ADB7F"), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loginUser(String email, String password) async {
    setState(() { _isLoading = true; });
    if (email.isNotEmpty && password.isNotEmpty) {
      try {
        final result = await ApiService.login(email, password);
        if (result['statusCode'] == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => BottomNavigationScreen(pageno: 2)),
          );
        } else {
          setState(() {
            _isLoading = false;
            bodyError = result['message'] ?? "Invalid Email Or Password";
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          bodyError = "Connection error. Check your network and server.";
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        bodyError = "Enter Details First !!!";
      });
    }
  }
}
