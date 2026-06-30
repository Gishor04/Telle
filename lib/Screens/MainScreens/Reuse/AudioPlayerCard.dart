import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../Helpers/Colors/Colors.dart';
import '../../../Helpers/Constants/TextStyle/Textstyle.dart';

class AudioCard extends StatefulWidget {
  final String image;
  final String title;
  final String url;

  AudioCard({
    Key? key,
    required this.image,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  _AudioCardState createState() => _AudioCardState();
}

class _AudioCardState extends State<AudioCard> {
  late AudioPlayer localPlayer;
  bool isPlaying = false;
  bool firstPlay = true;
  Duration currentDuration = Duration.zero;
  Duration totalDuration = Duration.zero;
  double playbackSpeed = 0.8;

  @override
  void initState() {
    print("Card Audio");
    print(widget.url);
    super.initState();
    localPlayer = AudioPlayer();
    localPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        setState(() {
          isPlaying = false;
        });
      }
    });
    localPlayer.positionStream.listen((position) {
      setState(() {
        currentDuration = position;
      });
    });
    localPlayer.durationStream.listen((duration) {
      setState(() {
        totalDuration = duration ?? Duration.zero;
      });
    });
  }

  void setPlaybackSpeed(double speed) {
    setState(() {
      playbackSpeed = speed;
    });
    localPlayer.setSpeed(speed);
  }

  Future<void> _playAudio(String audioUrl) async {
    if (isPlaying) {
      setState(() {
        isPlaying = false;
      });
      await localPlayer.stop();
    } else {
      setState(() {
        isPlaying = true;
      });
      if (firstPlay) {
        await localPlayer.setUrl(audioUrl);
        setState(() {
          firstPlay = false;
        });
      }
      await localPlayer.setSpeed(playbackSpeed); // Set speed before playing
      await localPlayer.play();
    }
  }

  @override
  void dispose() {
    localPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.02),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: primarygreyDark,
                fontFamily: 'play',
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.03),
          child: Container(
            height: screenHeight * 0.37,
            width: screenWidth * 0.8,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(widget.image),
                fit: BoxFit.fill,
              ),
              border: Border.all(
                color: HexColor("#EFFEE0"),
              ),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
        ),
        SizedBox(
          height: screenHeight * 0.02,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  currentDuration.toString().split('.').first,
                  style: authsubheadingstyle,
                ),
                Slider(
                  value: totalDuration.inMilliseconds > 0
                      ? currentDuration.inMilliseconds
                          .toDouble()
                          .clamp(0.0, totalDuration.inMilliseconds.toDouble())
                      : 0.0,
                  min: 0.0,
                  max: totalDuration.inMilliseconds > 0
                      ? totalDuration.inMilliseconds.toDouble()
                      : 0.0,
                  onChanged: (value) {
                    if (totalDuration.inMilliseconds > 0) {
                      localPlayer.seek(Duration(milliseconds: value.toInt()));
                    }
                  },
                ),
                Text(
                  totalDuration.toString().split('.').first,
                  style: authsubheadingstyle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${playbackSpeed.toStringAsFixed(1)}x',
                  style: authsubheadingstyle,
                ),
                Slider(
                  value: playbackSpeed,
                  min: 0.5,
                  max: 2.0,
                  onChanged: (value) {
                    setPlaybackSpeed(value);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.skip_previous,
                  ),
                  onPressed: () {
                    // Implement previous song functionality
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    _playAudio(widget.url);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: HexColor("#F1FFFC"),
                    fixedSize: Size(60, 60),
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: primaryblackColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: () {
                    // Implement next song functionality
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
