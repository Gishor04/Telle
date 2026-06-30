import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tellie/API/ApiService.dart';
import 'package:tellie/Helpers/Constants/Loader/Loader.dart';
import 'package:tellie/Screens/MainScreens/Reuse/OneTimeAudioCard.dart';

import '../../Helpers/Colors/Colors.dart';
import '../../Helpers/Constants/Lists/List.dart';

class PlaySpecificEmotionalAudio extends StatefulWidget {
  final String date;
  final String title;

  const PlaySpecificEmotionalAudio(
      {super.key, required this.date, required this.title});

  @override
  State<PlaySpecificEmotionalAudio> createState() =>
      _PlaySpecificEmotionalAudioState();
}

class _PlaySpecificEmotionalAudioState
    extends State<PlaySpecificEmotionalAudio> {
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ItemScrollController itemScrollController = ItemScrollController();
  bool _isLoading = false;
  List<String> DateAudiourlList = [];
  String? _userId;

  @override
  void initState() {
    getAudioForDate();
    super.initState();
  }

  Future<void> getAudioForDate() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    if (_userId == null) return;

    setState(() { _isLoading = true; });
    try {
      final data = await ApiService.getAudioByDate(_userId!, widget.date);
      if (data != null) {
        List<dynamic> audioUrls = data['audiourl'] ?? [];
        DateAudiourlList = List<String>.from(audioUrls);
      }
    } catch (e) {
      print('Error getting URLs: $e');
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  void DeleteDoc(String audiourl) async {
    if (_userId == null) return;
    try {
      await ApiService.removeAudioUrl(_userId!, widget.date, audiourl);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PlaySpecificEmotionalAudio(
            date: widget.date,
            title: widget.title,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final randomIndex = random.nextInt(images.length);
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? loader
          : SafeArea(
              child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "All Audios",
                      style: TextStyle(
                          fontSize: 25,
                          color: primarygreyDark,
                          fontFamily: 'play',
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    DateAudiourlList.isEmpty
                        ? Center(
                            child: Padding(
                            padding:
                                EdgeInsets.fromLTRB(0, screenHeight * 0.35, 0, 0),
                            child: Text("No Audio File"),
                          ))
                        : SizedBox(
                            height: screenHeight * 0.8,
                            child: ScrollablePositionedList.separated(
                                itemScrollController: itemScrollController,
                                itemPositionsListener: itemPositionsListener,
                                itemBuilder: ((context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PlayOneTimeEmotionalAudio(
                                                    image: images[randomIndex],
                                                    title: "Audio=>${index + 1}",
                                                    url: DateAudiourlList[index])),
                                      );
                                    },
                                    child: Container(
                                      height: screenHeight * 0.15,
                                      width: screenWidth,
                                      decoration: BoxDecoration(
                                          color: HexColor("#EBF7E3"),
                                          borderRadius: BorderRadius.circular(20)),
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      CircleAvatar(
                                                        backgroundImage:
                                                            AssetImage(images[randomIndex]),
                                                        radius: 30,
                                                      ),
                                                      SizedBox(width: screenWidth * 0.05),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "Audio ${index + 1}",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.bold,
                                                                color: primarygreyDark),
                                                          ),
                                                          SizedBox(height: screenHeight * 0.01),
                                                          Text(
                                                            widget.title.isEmpty
                                                                ? "Title : "
                                                                : "Title : ${widget.title}",
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 13),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  IconButton(
                                                      onPressed: () {
                                                        DeleteDoc(DateAudiourlList[index]);
                                                      },
                                                      icon: Icon(Icons.delete, color: Colors.red))
                                                ],
                                              )
                                            ]),
                                      ),
                                    ),
                                  );
                                }),
                                separatorBuilder: (BuildContext context, int index) {
                                  return SizedBox(height: 15);
                                },
                                itemCount: DateAudiourlList.length),
                          )
                  ],
                ),
              ),
            )),
    );
  }
}
