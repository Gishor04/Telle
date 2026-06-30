import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tellie/Helpers/Colors/Colors.dart';
import 'package:tellie/Helpers/Constants/TextStyle/Textstyle.dart';
import 'package:tellie/Screens/MainScreens/Reuse/AudioPlayerCard.dart';

import '../../../Helpers/Constants/Lists/List.dart';
import 'OneTimeAudioCard.dart';

final random = Random();
final randomIndex = random.nextInt(images.length);

class AudioAlert {
  static showAlertDialog(BuildContext context, String url) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    // Widget okButton = ElevatedButton(
    //   child: Text("OK"),
    //   onPressed: () {},
    // );
    AlertDialog alert = AlertDialog(
      backgroundColor: HexColor("#F3FFF1"),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      title: Center(
          child: Text(
        "Select One",
        style: authheadingstyle,
      )),
      content: Container(
          height: screenHeight * 0.3,
          width: screenWidth * 0.3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).pop();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PlayOneTimeEmotionalAudio(
                                  image: images[randomIndex],
                                  title: "",
                                  url: url)),
                        );
                      },
                      child: Container(
                        height: screenHeight * 1 / 10,
                        width: screenWidth * 3 / 5,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.green,
                                Colors.yellow,
                              ]),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            Text(""),
                            Text(
                              "PLAY AUDIO",
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white),
                                child: const Icon(
                                  Icons.graphic_eq_sharp,
                                  size: 25.0,
                                  color: Colors.green,
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.05,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      height: screenHeight * 1 / 10,
                      width: screenWidth * 3 / 5,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.yellow,
                              Colors.green,
                            ]),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          const Text(""),
                          const Text(
                            "PLAY VIDEO",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                          Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                              child: const Icon(
                                Icons.video_call,
                                size: 25.0,
                                color: Colors.green,
                              ))
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )),
      actions: [],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
