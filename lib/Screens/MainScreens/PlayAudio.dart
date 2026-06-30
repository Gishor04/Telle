// ignore_for_file: unused_import, prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tellie/Helpers/Colors/Colors.dart';
import 'package:tellie/Screens/MainScreens/Reuse/AudioPlayerCard.dart';
import 'package:text_to_speech/text_to_speech.dart';

import '../../Helpers/Constants/Texts/VoiceText.dart';

class PlayEmotionalAudio extends StatefulWidget {
  PlayEmotionalAudio({super.key});

  @override
  State<PlayEmotionalAudio> createState() => _PlayEmotionalAudioState();
}

class _PlayEmotionalAudioState extends State<PlayEmotionalAudio> {
  final player = AudioPlayer();
  FlutterTts ftts = FlutterTts();
  bool? EnableVoice;
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ItemScrollController itemScrollController = ItemScrollController();
  TextEditingController searchController = TextEditingController();
  TextToSpeech tts = TextToSpeech();
  String? Voicelanguage;

  @override
  void initState() {
    _loadVoiceSettings();
    super.initState();
  }

  @override
  void dispose() {
    player.stop();
    ftts.speak("");
    tts.stop();
    super.dispose();
  }

  void _loadVoiceSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final bool voiceEnabled = prefs.getBool('voice') ?? false;
    final String lang = prefs.getString('language') ?? 'English';
    if (voiceEnabled) {
      setState(() {
        EnableVoice = true;
        Voicelanguage = lang;
      });
      if (lang == "English") {
        ftts.speak(voiceEmotionAudioInit!);
      } else if (lang == "Sinhala") {
        tts.speak(voiceSinhalaEmotionAudioInit!);
      } else {
        tts.speak(voiceTamilEmotionAudioInit!);
      }
    }
  }

  final List cards = [
    {"image": 'assets/images/str5.jpeg', "title": 'Cindrellaa', "url": "assets/audio/cindrella.mp3"},
    {"image": 'assets/images/img5.png', "title": 'ShanChii', "url": "assets/audio/shanchi.mp3"},
    {"image": 'assets/images/img4.png', "title": 'Senorita', "url": "assets/audio/senorita.mp3"},
  ];

  final AudioPlayer globalPlayer = AudioPlayer();

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
                "Play Your Emotional Audio",
                style: TextStyle(
                    fontSize: 25,
                    color: primarygreyDark,
                    fontFamily: 'play',
                    fontWeight: FontWeight.bold),
              ),
              AnimSearchBar(
                searchIconColor: Colors.white,
                color: HexColor("#007958"),
                width: screenWidth * 0.9,
                textController: searchController,
                onSuffixTap: () {
                  setState(() { searchController.clear(); });
                },
                onSubmitted: (String) {},
              ),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: HexColor("#F1FFEC"),
                      border: Border.all(color: HexColor("#D9FCD9")),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  height: screenHeight * 0.68,
                  width: screenWidth,
                  child: PageView.builder(
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      return AudioCard(
                          image: cards[index]['image'],
                          title: cards[index]['title'],
                          url: cards[index]['url']);
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}
