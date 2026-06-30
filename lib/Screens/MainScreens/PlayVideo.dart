// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_unnecessary_containers, unnecessary_null_comparison
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tellie/Helpers/Constants/Texts/VoiceText.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:video_player/video_player.dart';
import '../../Helpers/Colors/Colors.dart';

class PlaySignVideo extends StatefulWidget {
  PlaySignVideo({super.key});

  @override
  State<PlaySignVideo> createState() => _PlaySignVideoState();
}

class _PlaySignVideoState extends State<PlaySignVideo> {
  late VideoPlayerController _controller;
  FlutterTts ftts = FlutterTts();
  TextToSpeech tts = TextToSpeech();
  bool? EnableVoice;
  bool? isPlaying = false;
  bool? videoStop = false;
  bool _controllerInitialized = false;
  String? selectedVideoUrl;
  String? Voicelanguage;

  List<Map<String, String>> video = [
    {"video": "Cinderella", "image": "assets/images/str5.jpeg", "url": "https://media.w3.org/2010/05/sintel/trailer.mp4"},
    {"video": "Your Name", "image": "assets/images/str2.jpeg", "url": "https://media.w3.org/2010/05/sintel/trailer.mp4"},
    {"video": "Shinchan", "image": "assets/images/str6.jpeg", "url": "https://media.w3.org/2010/05/sintel/trailer.mp4"},
    {"video": "DeathNote", "image": "assets/images/str7.jpeg", "url": "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4"},
  ];

  @override
  void initState() {
    _loadVoiceSettings();
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://media.w3.org/2010/05/sintel/trailer.mp4'));
    super.initState();
  }

  void playSignVideo(String videoUrl) {
    if (_controllerInitialized) {
      _controller.pause();
      _controller.dispose();
    }
    setState(() {
      isPlaying = false;
      _controllerInitialized = false;
      _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
        ..initialize().then((_) {
          setState(() {
            _controllerInitialized = true;
          });
          _controller.play();
          setState(() {
            isPlaying = true;
          });
        });
    });
  }

  @override
  void dispose() {
    ftts.speak("");
    tts.stop();
    _controller.dispose();
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
        ftts.speak(voiceEmotionVideoInit!);
      } else if (lang == "Sinhala") {
        tts.speak(voiceSinhalaEmotionVideoInit!);
      } else {
        tts.speak(voiceTamilEmotionVideoInit!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Play Your Sign Video Here",
              style: TextStyle(
                  fontSize: 25,
                  color: primaryappColor,
                  fontFamily: 'zyzol',
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: screenHeight * 0.03),
            Container(
              decoration: BoxDecoration(
                  color: HexColor("#F2FFF1"),
                  border: Border.all(color: HexColor("#D9FCD9")),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              height: screenHeight * 0.30,
              width: screenWidth,
              child: Center(
                child: _controllerInitialized && _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const Text("Select a video below to play"),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  onPressed: () {},
                ),
                ElevatedButton(
                    onPressed: () {
                      if (!_controllerInitialized) return;
                      setState(() {
                        isPlaying = !_controller.value.isPlaying;
                        if (isPlaying!) {
                          _controller.play();
                        } else {
                          _controller.pause();
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: HexColor("#F1FFFC"),
                        fixedSize: Size(60, 60)),
                    child: Icon(
                      isPlaying! ? Icons.pause : Icons.play_arrow,
                      color: primaryblackColor,
                    )),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),
            Container(
              height: screenHeight * 0.36,
              width: screenWidth,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: video.length,
                  itemBuilder: ((context, index) {
                    return GestureDetector(
                      onTap: () { playSignVideo(video[index]["url"]!); },
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(video[index]["image"]!),
                                fit: BoxFit.fill,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(20))),
                          height: screenHeight * 0.2,
                        ),
                      ),
                    );
                  })),
            ),
          ],
        ),
      )),
    );
  }
}
