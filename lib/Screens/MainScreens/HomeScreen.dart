// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:intl/intl.dart';
import 'package:tellie/API/ApiService.dart';
import 'package:tellie/Helpers/Colors/Colors.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:tellie/Helpers/Constants/Loader/Loader.dart';
import 'package:tellie/Helpers/Constants/TextStyle/Textstyle.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:tellie/Screens/MainScreens/Reuse/OneTimeAudioCard.dart';
import 'package:text_to_speech/text_to_speech.dart';

import '../../Helpers/Constants/Lists/List.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ItemScrollController itemScrollController = ItemScrollController();
  TextEditingController searchController = TextEditingController();
  TextToSpeech tts = TextToSpeech();
  bool _isLoading = false;
  final df = DateFormat('dd-MM-yyyy ');
  List<String> urlList = [];

  final List colors = [
    "#F7F7E3", "#EBF7E3", "#E3F7EC", "#EDF7E3", "#E3F7EB", "#E3F7F0"
  ];

  List specialforyou = [
    {"image": "assets/images/img7.png"},
    {"image": "assets/images/img6.png"},
    {"image": "assets/images/img5.png"},
    {"image": "assets/images/img4.png"},
    {"image": "assets/images/img1.png"},
    {"image": "assets/images/img2.png"},
    {"image": "assets/images/img3.png"},
  ];

  @override
  void initState() {
    getUrlsByDate();
    super.initState();
  }

  Future<void> getUrlsByDate() async {
    String? userId = await ApiService.getUserId();
    if (userId == null) return;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    setState(() { _isLoading = true; });
    try {
      final data = await ApiService.getAudioByDate(userId, formattedDate);
      if (data != null) {
        List<dynamic> audioUrls = data['audiourl'] ?? [];
        urlList = List<String>.from(audioUrls);
      }
    } catch (e) {
      print('Error getting URLs: $e');
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    final random = Random();
    final randomIndex = random.nextInt(images.length);
    final randomColorIndex = random.nextInt(colors.length);
    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? loader
          : SafeArea(
              child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimSearchBar(
                      searchIconColor: Colors.white,
                      color: HexColor("#007958"),
                      width: screenWidth * 0.9,
                      textController: searchController,
                      onSuffixTap: () { setState(() { searchController.clear(); }); },
                      onSubmitted: (String) {},
                    ),
                    ImageSlideshow(
                      height: screenHeight * 0.25,
                      width: screenWidth,
                      autoPlayInterval: 3000,
                      isLoop: true,
                      children: [
                        _slideShow("assets/images/str3.jpeg"),
                        _slideShow("assets/images/str2.jpeg"),
                        _slideShow("assets/images/str6.jpeg"),
                        _slideShow("assets/images/str5.jpeg"),
                        _slideShow("assets/images/str9.jpeg"),
                        _slideShow("assets/images/str8.jpeg"),
                        _slideShow("assets/images/str7.jpeg"),
                        _slideShow("assets/images/str1.jpeg"),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text("Special For You", style: authsubheadingstyle),
                    SizedBox(height: screenHeight * 0.02),
                    SizedBox(
                      height: screenHeight * 0.15,
                      width: screenWidth,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: specialforyou.length,
                          itemBuilder: ((context, index) {
                            return Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Container(
                                width: screenWidth * 0.27,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(specialforyou[index]["image"]),
                                      fit: BoxFit.fill,
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(20))),
                              ),
                            );
                          })),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Last Watch History", style: authsubheadingstyle),
                        Text("see all", style: authsubheadingstyle),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Padding(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: urlList.isNotEmpty
                            ? SizedBox(
                                height: screenHeight * 0.21,
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
                                                        url: urlList[index])),
                                          );
                                        },
                                        child: Container(
                                          height: screenHeight * 0.1,
                                          width: screenWidth * 0.01,
                                          decoration: BoxDecoration(
                                              color: HexColor(colors[randomColorIndex]),
                                              borderRadius: BorderRadius.circular(10)),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 15),
                                            child: Column(children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 25,
                                                    backgroundImage:
                                                        AssetImage(images[randomIndex]),
                                                  ),
                                                  Text(
                                                    "Audio=>${index + 1}",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: "poppinsregular"),
                                                  ),
                                                  Text(
                                                    df.format(DateTime.now()),
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: "poppinsregular"),
                                                  ),
                                                ],
                                              ),
                                            ]),
                                          ),
                                        ),
                                      );
                                    }),
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return SizedBox(height: 15);
                                    },
                                    itemCount: urlList.length),
                              )
                            : Center(
                                child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 60, 0, 0),
                                child: Text(" No Audio"),
                              )))
                  ],
                ),
              ),
            )),
    );
  }

  Widget _slideShow(String image) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(image), fit: BoxFit.fill),
          border: Border.all(color: primarywhitecolor),
          borderRadius: BorderRadius.all(Radius.circular(20))),
    );
  }
}
