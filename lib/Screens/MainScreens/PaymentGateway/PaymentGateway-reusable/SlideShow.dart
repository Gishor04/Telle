// // ignore_for_file: sized_box_for_whitespace, sort_child_properties_last, prefer_const_constructors
// import 'package:flutter/material.dart';
// import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
// import 'package:just_audio/just_audio.dart';
// import 'package:tellie/Helpers/Colors/Colors.dart';

// class PaymentSlideShow extends StatefulWidget {
//   PaymentSlideShow({
//     Key? key,
//   }) : super(key: key);

//   @override
//   _PaymentSlideShowState createState() => _PaymentSlideShowState();
// }

// class _PaymentSlideShowState extends State<PaymentSlideShow> {
//   @override
//   Widget build(BuildContext context) {
//     var screenHeight = MediaQuery.of(context).size.height;
//     var screenWidth = MediaQuery.of(context).size.width;
//     return ImageSlideshow(
//       height: screenHeight * 0.25,
//       width: screenWidth,
//       autoPlayInterval: 3000,
//       isLoop: true,
//       children: [
//         SlideShow("assets/images/str3.jpeg"),
//         SlideShow("assets/images/str2.jpeg"),
//         SlideShow("assets/images/str6.jpeg"),
//         SlideShow("assets/images/str5.jpeg"),
//         SlideShow("assets/images/str9.jpeg"),
//         SlideShow("assets/images/str8.jpeg"),
//         SlideShow("assets/images/str7.jpeg"),
//         SlideShow("assets/images/str1.jpeg"),
//       ],
//       // Container(
//     );
//   }

//   Widget SlideShow(String image) {
//     return Container(
//       decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(image),
//             fit: BoxFit.fill,
//           ),
//           border: Border.all(
//             color: primarywhitecolor,
//           ),
//           borderRadius: BorderRadius.all(Radius.circular(20))),
//     );
//   }
// }
