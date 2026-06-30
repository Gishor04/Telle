// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable, prefer_final_fields, sized_box_for_whitespace, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tellie/API/ApiService.dart';
import 'package:tellie/Helpers/Buttons/Button.dart';
import 'package:tellie/Helpers/Colors/Colors.dart';
import 'package:tellie/Helpers/Constants/Loader/Loader.dart';
import 'package:tellie/Helpers/Constants/TextStyle/Textstyle.dart';
import 'package:tellie/Helpers/Constants/Texts/Validation.dart';
import 'package:tellie/Screens/Authentication/Authentication-Reusable/SignUp-Resuable.dart';
import 'package:tellie/Screens/Authentication/AuthenticationMain/SigninScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool showPassword = true;
  bool _isLoading = false;
  String? bodyError;
  final regex = RegExp(Emailpattern);

  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController conformpasswordcontroller = TextEditingController();

  @override
  void initState() {
    setState(() { _isLoading = false; });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: IconButton(
                    onPressed: () { Navigator.pop(context); },
                    icon: Icon(Icons.arrow_back)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Create Your ",
                            style: TextStyle(fontSize: 20, color: primarygreyDark)),
                        SizedBox(width: 5),
                        Text("Account ",
                            style: TextStyle(
                                fontSize: 20,
                                color: primarygreyDark,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text("We are happy to see you here! ",
                        style: TextStyle(fontSize: 13, color: primarygreyLight)),
                    SizedBox(height: screenHeight * 0.04),
                    Container(
                      height: screenHeight * 0.2,
                      width: screenWidth,
                      child: Lottie.asset("assets/json/stackbook.json"),
                    ),
                    signuptextform(namecontroller, "Name", Icons.person),
                    SizedBox(height: screenHeight * 0.02),
                    signuptextform(emailcontroller, "Email", Icons.email),
                    SizedBox(height: screenHeight * 0.02),
                    signuptextformpassword(
                        passwordcontroller, obscurepsw, showPassword, "Password"),
                    SizedBox(height: screenHeight * 0.02),
                    signuptextformpassword(conformpasswordcontroller, obscurepsw,
                        showPassword, "Confirm Password"),
                    SizedBox(height: screenHeight * 0.01),
                    bodyError != null
                        ? Text(bodyError.toString(),
                            style: TextStyle(color: Colors.red))
                        : SizedBox(),
                    SizedBox(height: screenHeight * 0.04),
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
                              child: Text("Register", style: buttontextstyle),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HexColor("#2ADB7F"),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                registerUser(namecontroller.text,
                                    emailcontroller.text, passwordcontroller.text);
                              },
                            ),
                          ),
                    SizedBox(height: screenHeight * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already Have an Account"),
                        SizedBox(width: 7),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => LoginScreen()));
                          },
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: HexColor("#2ADB7F")),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void obscurepsw() {
    setState(() => showPassword = !showPassword);
  }

  Future<void> registerUser(String name, String email, String password) async {
    setState(() { _isLoading = true; });
    try {
      if (namecontroller.text.isEmpty ||
          emailcontroller.text.isEmpty ||
          passwordcontroller.text.isEmpty ||
          conformpasswordcontroller.text.isEmpty) {
        setState(() {
          bodyError = "*All Fields Must Be filled";
          _isLoading = false;
        });
      } else if (!regex.hasMatch(emailcontroller.text)) {
        setState(() {
          bodyError = "*Enter Valid Email Address";
          _isLoading = false;
        });
      } else if (passwordcontroller.text.length < 6) {
        setState(() {
          bodyError = "*Password Should be Greater than 6 Letters";
          _isLoading = false;
        });
      } else if (passwordcontroller.text != conformpasswordcontroller.text) {
        setState(() {
          bodyError = "*Password and Confirm Password Must be Same";
          _isLoading = false;
        });
      } else {
        final result = await ApiService.register(name, email, password);
        if (result['statusCode'] == 201) {
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginScreen()));
        } else {
          setState(() {
            bodyError = result['message'] ?? "Registration failed";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        bodyError = "Unable to reach the server. Please verify the backend is running.";
        _isLoading = false;
      });
    }
  }
}
