import 'package:flutter/material.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.mainBrown,
      appBar: AppBar(
        // page title
        title: const Text('Settings',
            style: TextStyle(
              color: Colors.white,
            )),
        backgroundColor: CustomColor.mainBrown,
        leading: IconButton(
            onPressed: () {
              Activity.finishActivity(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body: Center(
        child: Text(
          "Settings page",
          style: CommonStyles.commonTextStyle,
        ),
      ),
    );
  }
}
