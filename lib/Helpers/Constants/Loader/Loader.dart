import 'package:flutter/material.dart';
import 'package:tellie/Helpers/Colors/Colors.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

var loader = Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    // SpinKitWave()

    SpinKitFadingCube(color: HexColor("#2d753e"), size: 12),
    SpinKitFadingCube(color: HexColor("#2d753e"), size: 12),
    SpinKitFadingCube(color: HexColor("#2d753e"), size: 12),
  ],
);
