// ignore_for_file: prefer_const_constructors, sort_child_properties_last
import 'package:flutter/material.dart';

import '../Colors/Colors.dart';

Widget button(text, function) {
  return Center(
    child: Container(
      height: 60,
      width: 400,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30.0),
      ),
      child: ElevatedButton(
        child: Text(
          text,
          style: TextStyle(
              fontSize: 30,
              color: HexColor("#234F68"),
              fontWeight: FontWeight.bold,
              fontFamily: "poppinsbold"),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor("#2ADB7F"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // <-- Radius
          ),
        ),
        onPressed: () {
          function;
        },
      ),
    ),
  );
}
