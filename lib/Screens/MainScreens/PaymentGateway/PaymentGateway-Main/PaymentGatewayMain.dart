// // ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, prefer_typing_uninitialized_variables, unnecessary_null_comparison, prefer_if_null_operators
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_switch/flutter_switch.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tellie/Helpers/Colors/Colors.dart';
// import 'package:tellie/Helpers/Constants/TextStyle/Textstyle.dart';
// import 'package:toggle_switch/toggle_switch.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import '../../../../Helpers/Buttons/Button.dart';
// import '../../../../Helpers/Constants/Functions/CommonFunction.dart';
// import '../PaymentGateway-reusable/PaymentGateway-reusable.dart';

// class PaymentGatewayScreen extends StatefulWidget {
//   final String payamount;
//   const PaymentGatewayScreen({super.key, required this.payamount});

//   @override
//   State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
// }

// class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
//   int secondsRemaining = 600;
//   late Timer timer;
//   var currentSelectedValue;
//   var selectedvalue = 0;
//   var cardtype;
//   bool status = false;
//   bool timeout = true;
//   TextEditingController paymentcardnocontroller = TextEditingController();
//   TextEditingController paymentcvccontroller = TextEditingController();
//   TextEditingController paymentexpirycontroller = TextEditingController();
//   List<String> bankType = ["HNB", "BOC", "CMR", "Sampath"];
//   late final String payamount;
//   @override
//   void initState() {
//     payamount = widget.payamount;
//     print(paymentcardnocontroller);
//     timer = Timer.periodic(Duration(seconds: 1), (_) {
//       if (secondsRemaining != 0) {
//         setState(() {
//           secondsRemaining--;
//         });
//       } else {
//         setState(() {
//           timeout = false;
//         });
//       }
//     });
//     // getdetails();
//     super.initState();
//   }

//   // void getdetails() async {
//   //   SharedPreferences localStorage = await SharedPreferences.getInstance();
//   //   var cardnumber = localStorage.getString('cardnumber');
//   //   var expiry = localStorage.getString('expiry');
//   //   var cvc = localStorage.getString('cvc');
//   //   var bank = localStorage.getString('bank');
//   //   var cardtype = localStorage.getString('cardtype');
//   //   print("januyan januyan januyan januyan januyan januyan januyan");
//   //   print(cardnumber);
//   //   print(expiry);
//   //   print(cvc);
//   //   print(bank);
//   //   print(cardtype);
//   // }

//   @override
//   Widget build(BuildContext context) {
//     var screenheight = MediaQuery.of(context).size.height;
//     var screenwidth = MediaQuery.of(context).size.width;
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//           child: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     icon: Icon(
//                       Icons.arrow_back,
//                       color: Colors.black,
//                     ),
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                   Text(formatDuration(secondsRemaining),
//                       style: TextStyle(color: Colors.red))
//                 ],
//               ),
//             ),
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: 30, horizontal: 40),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Payable Amount",
//                         style: authsubheadingstyle,
//                       ),
//                       Text(
//                         payamount != null ? payamount + " USD" : "0",
//                         style: authsubheadingstyle,
//                       )
//                     ],
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   ///////
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Bank",
//                         style: authheadingstyle,
//                       ),
//                       DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           hint: Text("Select"),
//                           value: currentSelectedValue,
//                           isDense: true,
//                           onChanged: (newValue) {
//                             setState(() {
//                               currentSelectedValue = newValue;
//                             });
//                           },
//                           items: bankType.map((String value) {
//                             return DropdownMenuItem<String>(
//                               value: value,
//                               child: Text(value),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ],
//                   ),

//                   SizedBox(
//                     height: 20,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Card Type",
//                         style: authsubheadingstyle,
//                       ),
//                       ToggleSwitch(
//                         minWidth: 35.0,
//                         minHeight: 35.0,
//                         cornerRadius: 5.0,
//                         activeBgColors: [
//                           [Color(0xfffdbb0a)],
//                           [HexColor("#011880")],
//                           [HexColor("#B1624EFF")]
//                         ],
//                         inactiveFgColor: Colors.white,
//                         initialLabelIndex: selectedvalue,
//                         totalSwitches: 3,
//                         customIcons: [
//                           Icon(
//                             FontAwesomeIcons.ccVisa,
//                             color: Color(0xff1a1f71),
//                             size: 15.0,
//                           ),
//                           Icon(
//                             FontAwesomeIcons.ccMastercard,
//                             color: Color(0xffF79E1B),
//                             size: 15.0,
//                           ),
//                           Icon(
//                             FontAwesomeIcons.paypal,
//                             color: Color(0xff27AEE3),
//                             size: 15.0,
//                           )
//                         ],
//                         onToggle: (index) {
//                           setState(() {
//                             selectedvalue = index!;
//                             if (selectedvalue == 0) {
//                               setState(() {
//                                 cardtype == "visa";
//                               });
//                             } else if (selectedvalue == 1) {
//                               setState(() {
//                                 cardtype = "mastercard";
//                               });
//                             } else {
//                               setState(() {
//                                 cardtype = "paypal";
//                               });
//                             }
//                           });
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             // PaymentSlideShow(),
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
//               child: Column(
//                 children: [
//                   paymentgatewattextform(paymentcardnocontroller, "Card Number",
//                       TextInputType.number),
//                   SizedBox(
//                     height: screenheight * 0.02,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       SizedBox(
//                         // height: 75,
//                         width: screenwidth * 0.4,
//                         child: paymentgatewaysubtextformExpiry(
//                             paymentexpirycontroller,
//                             "Expiry",
//                             TextInputType.number),
//                       ),
//                       SizedBox(
//                         width: screenwidth * 0.4,
//                         child: paymentgatewaysubtextformcvc(
//                             paymentcvccontroller, "CVC", TextInputType.number),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 80),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   Text(
//                     "Save Your card",
//                     style: authsubheadingstyle,
//                   ),
//                   Container(
//                     child: FlutterSwitch(
//                       width: 40.0,
//                       height: 23.0,
//                       valueFontSize: 15.0,
//                       toggleSize: 10.0,
//                       value: status,
//                       borderRadius: 20.0,
//                       padding: 8.0,
//                       onToggle: (val) {
//                         setState(() {
//                           status = val;
//                         });
//                         if (status == true) {
//                           // MySharedPreferences.instance.setStringValue(
//                           //     "cardnumber", paymentcardnocontroller.text);
//                           // MySharedPreferences.instance.setStringValue(
//                           //     "expiry", paymentexpirycontroller.text);
//                           // MySharedPreferences.instance
//                           //     .setStringValue("cvc", paymentcvccontroller.text);
//                           // MySharedPreferences.instance.setStringValue(
//                           //     "bank", currentSelectedValue.toString());
//                           // MySharedPreferences.instance
//                           //     .setStringValue("cardtype", cardtype.toString());
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             timeout
//                 ? Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 30, horizontal: 80),
//                     child: button("Proceed", ""),
//                   )
//                 : SizedBox(
//                     height: screenheight * 0.1,
//                     child: Center(
//                       child: Text(
//                         "Time Out !!! ",
//                         style: TextStyle(color: Colors.red),
//                       ),
//                     ),
//                   ),
//             Padding(
//               padding: EdgeInsets.symmetric(vertical: 10, horizontal: 60),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   DropdownButtonHideUnderline(
//                     child: DropdownButton<String>(
//                       hint: Text("Quick Pay"),
//                       value: currentSelectedValue,
//                       isDense: true,
//                       onChanged: (newValue) {
//                         setState(() {
//                           currentSelectedValue = newValue;
//                         });
//                       },
//                       items: bankType.map((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child: Text(value),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                   ElevatedButton(
//                       onPressed: () {},
//                       child: Text('QuickPay'),
//                       style: ElevatedButton.styleFrom(
//                           primary: HexColor("#baa1bf")))
//                 ],
//               ),
//             )
//           ],
//         ),
//       )),
//     );
//   }
// }
