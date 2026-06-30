// ignore_for_file: unused_import, prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'dart:math';

import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tellie/Helpers/Colors/Colors.dart';
import 'package:tellie/Screens/MainScreens/Reuse/AudioPlayerCard.dart';
import 'package:text_to_speech/text_to_speech.dart';

class PlayOneTimeEmotionalAudio extends StatefulWidget {
  final String image;
  final String title;
  final String url;

  PlayOneTimeEmotionalAudio(
      {super.key, required this.image, required this.title, required this.url});

  @override
  State<PlayOneTimeEmotionalAudio> createState() =>
      _PlayOneTimeEmotionalAudioState();
}

class _PlayOneTimeEmotionalAudioState extends State<PlayOneTimeEmotionalAudio> {
  TextEditingController searchController = TextEditingController();
  List<String> dataList = [];
  late String image;
  late String title;
  late String url;

  List colors = [
    HexColor("#F0F9FF"), HexColor("#F0FFFB"), HexColor("#F0FFF4"),
    HexColor("#F3FFF0"), HexColor("#FBFFF0"), HexColor("#FFFAF0"),
    HexColor("#F7F8FF"), HexColor("#F9F7FF"), HexColor("#FDF7FF"),
    HexColor("#FFF7FC"),
  ];

  Random random = Random();
  int index = 0;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), () { changeIndex(); });
    image = widget.image;
    title = widget.title;
    url = widget.url;
    super.initState();
  }

  void changeIndex() {
    setState(() => index = random.nextInt(7));
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "",
                style: TextStyle(
                    fontSize: 25,
                    color: primarygreyDark,
                    fontFamily: 'play',
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.1),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: colors[index],
                      border: Border.all(color: HexColor("#E7FFE2")),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  height: screenHeight * 0.68,
                  width: screenWidth,
                  child: PageView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return AudioCard(image: image, title: title, url: url);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
