// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tellie/Helpers/Colors/Colors.dart';
import 'package:tellie/Screens/MainScreens/AllAudiosByDate.dart';
import 'package:tellie/Screens/MainScreens/CaptureImage.dart';
import 'package:tellie/Screens/MainScreens/EditProfile.dart';
import 'package:tellie/Screens/MainScreens/HomeScreen.dart';
import 'package:tellie/Screens/MainScreens/PlayAudio.dart';
import 'package:tellie/Screens/MainScreens/PlayVideo.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class BottomNavigationScreen extends StatefulWidget {
  final int pageno;
  const BottomNavigationScreen({super.key, required this.pageno});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int maxCount = 4;
  late StreamSubscription _subscription;
  String netstatus = '';
  int _currentPage = 2; // Set initial page index to 2 (HomeScreen)
  final _pageController = PageController(initialPage: 2);

  Widget? _child;
  var _currentIndex = 0;
  @override
  void initState() {
    _currentIndex = widget.pageno;

    checkConnection();
    _subscription =
        Connectivity().onConnectivityChanged.listen((connectionStatus) {
      setState(() {
        netstatus = 'Connection status = ' + connectionStatus.first.name.toString();
      });
      checkConnection();
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future checkConnection() async {
    final connectionStatus = await Connectivity().checkConnectivity();
    if (connectionStatus == ConnectivityResult.mobile) {
      setState(() {
        netstatus = 'mobiledata';
      });
    } else if (connectionStatus == ConnectivityResult.wifi) {
      setState(() {
        netstatus = 'wifi';
      });
    } else {
      setState(() {
        netstatus = 'No';
      });
    }
  }

  final List<Widget> _screens = [
    AllEmotionalAudiosBydate(),
    PlaySignVideo(),
    HomeScreen(),
    CaptureImage(),
    EditProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0.0;
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        curve: Curves.linear,
        backgroundColor: HexColor("#ECFFEC"),
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          SalomonBottomBarItem(
            icon: Icon(Icons.audiotrack),
            title: Text("Audio"),
            selectedColor: Colors.greenAccent.shade700,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.video_camera_back),
            title: Text("Video"),
            selectedColor: Colors.greenAccent.shade700,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.home),
            title: Text("Home"),
            selectedColor: Colors.greenAccent.shade700,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.camera_alt_sharp),
            title: Text("Camera"),
            selectedColor: Colors.greenAccent.shade700,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.person),
            title: Text("Profile"),
            selectedColor: Colors.greenAccent.shade700,
          ),
        ],
      ),
      // body: PageView(
      //   controller: _pageController,
      //   children: [
      //     PlayEmotionalAudio(),
      //     PlaySignVideo(),
      //     HomeScreen(),
      //     CaptureImage(),
      //     EditProfile(),
      //   ],
      //   onPageChanged: (index) {
      //     setState(() => _currentPage = index);
      //   },
      // ),
      // bottomNavigationBar: BottomBar(
      //   curve: Curves.linear,
      //   backgroundColor: HexColor("#ECFFEC"),
      //   selectedIndex: _currentPage,
      //   onTap: (int index) {
      //     _pageController.jumpToPage(index);
      //     setState(() => _currentPage = index);
      //   },
      //   items: <BottomBarItem>[
      //     BottomBarItem(
      //       icon: Icon(Icons.audiotrack),
      //       title: Text('Audio'),
      //       // activeColor: Colors.blue,
      //       activeColor: Colors.greenAccent.shade700,
      //     ),
      //     BottomBarItem(
      //       icon: Icon(Icons.video_camera_back),
      //       title: Text('Video'),
      //       // activeColor: Colors.red,
      //       activeColor: Colors.greenAccent.shade700,
      //     ),
      //     BottomBarItem(
      //       icon: Icon(Icons.home),
      //       title: Text('Home'),
      //       activeColor: Colors.greenAccent.shade700,
      //     ),
      //     BottomBarItem(
      //       icon: Icon(Icons.camera_alt_sharp),
      //       title: Text('Image'),
      //       // activeColor: Colors.orange,
      //       activeColor: Colors.greenAccent.shade700,
      //     ),
      //     BottomBarItem(
      //       icon: Icon(Icons.person),
      //       title: Text('Profile'),
      //       // activeColor: Colors.purple,
      //       activeColor: Colors.greenAccent.shade700,
      //     ),
      //   ],
      // ),
    );
  }
}
