// // ignore_for_file: unnecessary_this

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:intl/intl.dart';

// import '../../Colors/Colors.dart';

// String getFormattedDate(String date) {
//   var localDate = DateTime.parse(date).toLocal();
//   var inputFormat = DateFormat('yyyy-MM-dd HH:mm');
//   var inputDate = inputFormat.parse(localDate.toString());
//   var outputFormat = DateFormat('dd/MM/yyyy');
//   var outputDate = outputFormat.format(inputDate);
//   return outputDate.toString();
// }

// String formatDuration(int totalSeconds) {
//   final duration = Duration(seconds: totalSeconds);
//   final minutes = duration.inMinutes;
//   final seconds = totalSeconds % 60;
//   final minutesString = '$minutes'.padLeft(2, '0');
//   final secondsString = '$seconds'.padLeft(2, '0');
//   return '$minutesString:$secondsString';
// }

// toastmessage(messgae) => Fluttertoast.showToast(
//     msg: messgae,
//     toastLength: Toast.LENGTH_SHORT,
//     gravity: ToastGravity.BOTTOM,
//     timeInSecForIosWeb: 1,
//     backgroundColor: HexColor("#D9A383"),
//     textColor: Colors.black,
//     fontSize: 16.0);

// extension StringNumberExtension on String {
//   String spaceSeparateNumbers() {
//     final result = this.replaceAllMapped(
//         RegExp(r'(\d{1,4})(?=(\d{4})+(?!\d))'), (Match m) => '${m[1]} ');
//     return result;
//   }
// }

// class CustomInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     var text = newValue.text;

//     if (newValue.selection.baseOffset == 0) {
//       return newValue;
//     }

//     var buffer = new StringBuffer();
//     for (int i = 0; i < text.length; i++) {
//       buffer.write(text[i]);
//       var nonZeroIndex = i + 1;
//       if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
//         buffer.write(
//             ' '); // Replace this with anything you want to put after each 4 numbers
//       }
//     }

//     var string = buffer.toString();
//     return newValue.copyWith(
//         text: string,
//         selection: TextSelection.collapsed(offset: string.length));
//   }
// }

// class CardExpirationFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     final newValueString = newValue.text;
//     String valueToReturn = '';

//     for (int i = 0; i < newValueString.length; i++) {
//       if (newValueString[i] != '/') valueToReturn += newValueString[i];
//       var nonZeroIndex = i + 1;
//       final contains = valueToReturn.contains(RegExp(r'\/'));
//       if (nonZeroIndex % 2 == 0 &&
//           nonZeroIndex != newValueString.length &&
//           !(contains)) {
//         valueToReturn += '/';
//       }
//     }
//     return newValue.copyWith(
//       text: valueToReturn,
//       selection: TextSelection.fromPosition(
//         TextPosition(offset: valueToReturn.length),
//       ),
//     );
//   }
// }
