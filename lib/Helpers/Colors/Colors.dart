import 'dart:ui';
import 'package:flutter/material.dart';

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}

//Major Colors
HexColor primarygreencolor = HexColor("#14FF85");
HexColor textfieldinnercolor = HexColor("#F5F4F8");
HexColor textfieldtextcolor = HexColor("#A1A5C1");
HexColor textfieldiconcolor = HexColor("#252B5C");
const primarywhitecolor = Colors.white;
HexColor primarygreyDark = HexColor("#252B5C");
HexColor primarygreyLight = HexColor("#53587A");
HexColor primarybtnColor = HexColor("#027AFE");
const primaryblackColor = Colors.black;
HexColor backgroundColor = HexColor("#F8FEF9");
HexColor primaryappColor = HexColor("#3A855D");
