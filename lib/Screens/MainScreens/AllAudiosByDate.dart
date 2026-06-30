import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tellie/API/ApiService.dart';
import 'package:tellie/Helpers/Constants/Loader/Loader.dart';
import 'package:tellie/Screens/BottomNavigationBar/BottomNavigation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tellie/Screens/MainScreens/PlaySpecificEmotionalAudio.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:text_to_speech/text_to_speech.dart';

import '../../Helpers/Colors/Colors.dart';
import '../../Helpers/Constants/Lists/List.dart';
import '../../Helpers/Constants/Texts/VoiceText.dart';
import 'Reuse/CustomAlert.dart';

enum Share {
  facebook,
  messenger,
  twitter,
  whatsapp,
  whatsapp_personal,
  whatsapp_business,
  share_system,
  share_instagram,
  share_telegram
}

class AllEmotionalAudiosBydate extends StatefulWidget {
  const AllEmotionalAudiosBydate({super.key});

  @override
  State<AllEmotionalAudiosBydate> createState() =>
      _AllEmotionalAudiosBydateState();
}

class _AllEmotionalAudiosBydateState extends State<AllEmotionalAudiosBydate> {
  List specialforyou = [
    {"image": "assets/animals/cat.jpeg"},
    {"image": "assets/animals/lion.jpeg"},
    {"image": "assets/animals/tiger.jpeg"},
    {"image": "assets/animals/wolf.jpeg"},
    {"image": "assets/animals/fox.jpeg"},
    {"image": "assets/animals/elephant.jpeg"},
    {"image": "assets/animals/monkey.jpeg"},
    {"image": "assets/animals/crocodile.jpeg"},
    {"image": "assets/animals/dog.jpeg"},
    {"image": "assets/animals/zebra.jpeg"},
  ];
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ItemScrollController itemScrollController = ItemScrollController();
  TextEditingController _textFieldController = TextEditingController();
  bool _isLoading = false;
  List<String> AllDatesList = [];
  List<String> AllNameList = [];
  String? userId;
  bool? titleloading = false;
  FlutterTts ftts = FlutterTts();
  TextToSpeech tts = TextToSpeech();
  bool? EnableVoice;
  String? Voicelanguage;
  String? userName;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    ftts.speak("");
    tts.stop();
    super.dispose();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    userName = prefs.getString('userName');
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

    await _fetchAudioData();
  }

  Future<void> _fetchAudioData() async {
    if (userId == null) return;
    setState(() { _isLoading = true; });
    try {
      final List<dynamic> audios = await ApiService.getAllAudioDates(userId!);
      AllDatesList.clear();
      AllNameList.clear();
      for (var audio in audios) {
        AllDatesList.add(audio['date'] as String);
        AllNameList.add(audio['title'] as String? ?? 'Title...');
      }
      setState(() {
        _isLoading = false;
        titleloading = true;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    "All Saved Audios",
                    style: TextStyle(
                        fontSize: 25,
                        color: primaryappColor,
                        fontFamily: 'zyzol',
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  AllDatesList.isEmpty
                      ? Center(child: Text("No Saved Audio"))
                      : SizedBox(
                          height: screenHeight * 0.76,
                          child: ScrollablePositionedList.separated(
                              itemScrollController: itemScrollController,
                              itemPositionsListener: itemPositionsListener,
                              itemBuilder: ((context, index) {
                                return GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    height: screenHeight * 0.4,
                                    width: screenWidth,
                                    decoration: BoxDecoration(
                                        color: HexColor("#E3F7EC"),
                                        borderRadius: BorderRadius.circular(20)),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Padding(
                                              padding: EdgeInsets.only(top: 10),
                                              child: titleloading!
                                                  ? Text(
                                                      AllNameList[index],
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 20),
                                                    )
                                                  : CupertinoActivityIndicator()),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                      radius: 20,
                                                      backgroundImage: AssetImage("assets/images/abi.png")),
                                                  SizedBox(width: screenHeight * 0.01),
                                                  Text(userName ?? "")
                                                ],
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    onButtonTap(Share.whatsapp);
                                                  },
                                                  icon: Icon(Icons.share_sharp)),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      PlaySpecificEmotionalAudio(
                                                        date: AllDatesList[index],
                                                        title: AllNameList[index],
                                                      )),
                                            );
                                          },
                                          child: Container(
                                            height: screenHeight * 0.23,
                                            width: screenWidth,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image(
                                                  fit: BoxFit.cover,
                                                  image: AssetImage("assets/images/abi.png")),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: screenHeight * 0.01),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(
                                              screenWidth * 0.04,
                                              screenWidth * 0.03,
                                              screenWidth * 0.04,
                                              screenWidth * 0.02),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AllDatesList[index],
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  _displayTextInputDialog(
                                                      context, AllDatesList[index]);
                                                },
                                                child: Text(
                                                  "Update Title",
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.green),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              separatorBuilder: (BuildContext context, int index) {
                                return SizedBox(height: 15);
                              },
                              itemCount: AllDatesList.length),
                        )
                ],
              ),
            ))),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context, String date) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Set Title For the Audio List'),
            content: TextField(
              onChanged: (value) {},
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter Your Title"),
            ),
            actions: <Widget>[
              MaterialButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () async {
                  if (_textFieldController.text.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "Cannot Be Empty",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  } else {
                    if (userId != null) {
                      await ApiService.updateAudioTitle(
                          userId!, date, _textFieldController.text);
                    }
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => BottomNavigationScreen(pageno: 0),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        });
  }

  Future<void> onButtonTap(Share share) async {
    String msg = ' Sharing is Caring!!\n Check out full Audio at www.tellie.pro';
    String url = 'https://pub.dev/packages/flutter_share_me';
    String? response;
    final FlutterShareMe flutterShareMe = FlutterShareMe();
    switch (share) {
      case Share.facebook:
        response = await flutterShareMe.shareToFacebook(url: url, msg: msg);
        break;
      case Share.messenger:
        response = await flutterShareMe.shareToMessenger(url: url, msg: msg);
        break;
      case Share.twitter:
        response = await flutterShareMe.shareToTwitter(url: url, msg: msg);
        break;
      case Share.whatsapp:
        response = await flutterShareMe.shareToWhatsApp(msg: msg);
        break;
      case Share.whatsapp_business:
        response = await flutterShareMe.shareToWhatsApp(msg: msg);
        break;
      case Share.share_system:
        response = await flutterShareMe.shareToSystem(msg: msg);
        break;
      case Share.whatsapp_personal:
        response = await flutterShareMe.shareWhatsAppPersonalMessage(
            message: msg, phoneNumber: 'phone-number-with-country-code');
        break;
      case Share.share_instagram:
        break;
      case Share.share_telegram:
        response = await flutterShareMe.shareToTelegram(msg: msg);
        break;
    }
    debugPrint(response);
  }
}
