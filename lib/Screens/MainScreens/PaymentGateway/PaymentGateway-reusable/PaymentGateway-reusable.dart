// // ignore_for_file: prefer_const_constructors
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:tellie/Helpers/Colors/Colors.dart';

// import '../../../../Helpers/Constants/Functions/CommonFunction.dart';

// Widget paymentgatewattextform(controller, hinttext, inputtype) {
//   return TextFormField(
//     inputFormatters: [
//       FilteringTextInputFormatter.digitsOnly,
//       CustomInputFormatter()
//     ],
//     controller: controller,
//     validator: (value) {
//       if (value!.isEmpty) {
//         return 'Required';
//       }

//       return null;
//     },
//     decoration: InputDecoration(
//       filled: true,
//       fillColor: Colors.grey[300],
//       hintText: hinttext,

//       // suffixIcon: Icon(Icons.person),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(15.0),
//         borderSide: BorderSide(
//           color: primarywhitecolor,
//         ),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(15.0),
//         borderSide: BorderSide(
//           width: 2.0,
//           color: primarywhitecolor,
//         ),
//       ),
//     ),
//     keyboardType: inputtype,
//     style: TextStyle(
//       fontFamily: "Poppins",
//     ),
//   );
// }

// Widget paymentgatewaysubtextformExpiry(controller, hinttext, inputtype) {
//   return TextFormField(
//     maxLength: 5,
//     inputFormatters: [
//       FilteringTextInputFormatter.digitsOnly,
//       CardExpirationFormatter()
//     ],
//     controller: controller,
//     validator: (value) {
//       if (value!.isEmpty) {
//         return 'Required';
//       }

//       return null;
//     },
//     decoration: InputDecoration(
//       filled: true,
//       fillColor: Colors.grey[300],
//       hintText: hinttext,

//       // suffixIcon: Icon(Icons.person),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(15.0),
//         borderSide: BorderSide(
//           color: primarywhitecolor,
//         ),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(15.0),
//         borderSide: BorderSide(
//           width: 2.0,
//           color: primarywhitecolor,
//         ),
//       ),
//     ),
//     keyboardType: inputtype,
//     style: TextStyle(
//       fontFamily: "Poppins",
//     ),
//   );
// }

// Widget paymentgatewaysubtextformcvc(controller, hinttext, inputtype) {
//   return TextFormField(
//     maxLength: 3,
//     controller: controller,
//     validator: (value) {
//       if (value!.isEmpty) {
//         return 'Required';
//       }

//       return null;
//     },
//     decoration: InputDecoration(
//       filled: true,
//       fillColor: Colors.grey[300],
//       hintText: hinttext,

//       // suffixIcon: Icon(Icons.person),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(15.0),
//         borderSide: BorderSide(
//           color: primarywhitecolor,
//         ),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(15.0),
//         borderSide: BorderSide(
//           width: 2.0,
//           color: primarywhitecolor,
//         ),
//       ),
//     ),
//     keyboardType: inputtype,
//     style: TextStyle(
//       fontFamily: "Poppins",
//     ),
//   );
// }
