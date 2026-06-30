// ignore_for_file: avoid_single_cascade_in_expression_statements, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tellie/API/ApiService.dart';
import 'package:tellie/Helpers/Colors/Colors.dart';
import 'package:tellie/Screens/Authentication/AuthenticationMain/SigninScreen.dart';
import 'package:tellie/Screens/MainScreens/ImageCaption.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String? userId;
  bool? isEnable;
  bool? buttonEnable = false;
  String? userName;
  int? langindex;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 1), () {
      _loadUserData();
    });
    super.initState();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    final bool voiceEnabled = prefs.getBool('voice') ?? false;
    final String lang = prefs.getString('language') ?? 'English';
    final String? name = prefs.getString('userName');

    if (lang == "Sinhala") {
      setState(() { langindex = 0; });
    } else if (lang == "Tamil") {
      setState(() { langindex = 1; });
    } else {
      setState(() { langindex = 2; });
    }

    setState(() {
      buttonEnable = true;
      isEnable = voiceEnabled;
      userName = name;
    });

    // Refresh from server
    if (userId != null) {
      final profile = await ApiService.getUserProfile(userId!);
      if (profile != null) {
        final bool serverVoice = profile['voice'] as bool? ?? false;
        final String serverLang = profile['language'] as String? ?? 'English';
        final String serverName = profile['name'] as String? ?? '';
        int idx = serverLang == "Sinhala" ? 0 : serverLang == "Tamil" ? 1 : 2;
        setState(() {
          isEnable = serverVoice;
          langindex = idx;
          userName = serverName;
        });
      }
    }
  }

  void _showEditNameDialog(BuildContext context) {
    final TextEditingController nameController =
        TextEditingController(text: userName ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Enter your name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;
              Navigator.of(ctx).pop();
              if (userId != null) {
                final ok =
                    await ApiService.updateUserSettings(userId!, name: newName);
                if (ok) {
                  setState(() {
                    userName = newName;
                  });
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: ListView(
          children: [
            BigUserCard(
              backgroundColor: primarygreyDark,
              userName: userName ?? "",
              userProfilePic: AssetImage("assets/images/kakashi.png"),
              cardActionWidget: SettingsItem(
                icons: Icons.edit,
                iconStyle: IconStyle(
                  withBackground: true,
                  borderRadius: 50,
                  backgroundColor: Colors.yellow[600],
                ),
                title: "Modify",
                subtitle: "Tap to change your data",
                onTap: () {
                  _showEditNameDialog(context);
                },
              ),
            ),
            SettingsGroup(items: [
              SettingsItem(
                onTap: () {
                  _showComingSoon(context, 'LeaderBoard');
                },
                icons: CupertinoIcons.pencil_outline,
                iconStyle: IconStyle(),
                title: 'LeaderBoard',
                subtitle: "Global Leader Board ",
              ),
            ]),
            SettingsGroup(
              items: [
                SettingsItem(
                  icons: Icons.graphic_eq_sharp,
                  iconStyle: IconStyle(
                    iconsColor: Colors.white,
                    withBackground: true,
                    backgroundColor: Colors.red,
                  ),
                  title: 'Voice Assistant',
                  subtitle: "Automatic",
                  trailing: buttonEnable == false
                      ? Text("")
                      : Switch.adaptive(
                          value: isEnable ?? false,
                          onChanged: (bool value) async {
                            setState(() { isEnable = value; });
                            if (userId != null) {
                              await ApiService.updateUserSettings(userId!, voice: value);
                            }
                          },
                        ),
                ),
                SettingsItem(
                  icons: Icons.language,
                  iconStyle: IconStyle(
                    iconsColor: Colors.white,
                    withBackground: true,
                    backgroundColor: Colors.green,
                  ),
                  title: 'Voice Language',
                  subtitle: "SI || TA || EN",
                  trailing: buttonEnable == false
                      ? Text("")
                      : ToggleSwitch(
                          activeBgColor: [primarygreyDark],
                          dividerMargin: 3,
                          minHeight: 30,
                          minWidth: 40,
                          initialLabelIndex: langindex,
                          totalSwitches: 3,
                          labels: ['Si', 'Ta', 'En'],
                          onToggle: (index) async {
                            String lang = index == 0 ? "Sinhala" : index == 1 ? "Tamil" : "English";
                            if (userId != null) {
                              await ApiService.updateUserSettings(userId!, language: lang);
                            }
                          },
                        ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {},
              child: SettingsGroup(
                items: [
                  SettingsItem(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ImageCaption()),
                      );
                    },
                    icons: Icons.image_aspect_ratio,
                    iconStyle: IconStyle(backgroundColor: Colors.purple),
                    title: 'ImageCaption',
                    subtitle: "Caption Your Image",
                  ),
                ],
              ),
            ),
            SettingsGroup(
              settingsGroupTitle: "Account",
              items: [
                SettingsItem(
                  onTap: () { signOutUser(); },
                  icons: Icons.exit_to_app_rounded,
                  title: "Sign Out",
                  titleStyle: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SettingsItem(
                  onTap: () {
                    _showComingSoon(context, 'Upgrade to Premium');
                  },
                  icons: CupertinoIcons.star_circle_fill,
                  title: "Upgrade to Premium",
                  titleStyle: TextStyle(
                    color: primarygreyLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> signOutUser() async {
    PanaraConfirmDialog.showAnimatedGrow(
      context,
      title: "Are You Sure",
      message: "SignOut From Tellie",
      confirmButtonText: "Confirm",
      cancelButtonText: "Cancel",
      color: Colors.red,
      onTapCancel: () { Navigator.pop(context); },
      onTapConfirm: () async {
        try {
          Navigator.of(context, rootNavigator: true).pop();
          await ApiService.logout();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } catch (e) {
          print('Error during sign out: $e');
        }
      },
      panaraDialogType: PanaraDialogType.success,
      barrierDismissible: false,
    );
  }
}
