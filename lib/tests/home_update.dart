import 'package:flutter/material.dart';
import 'package:rockland/pages/home/profile.dart';
import 'package:rockland/styles/colors.dart';

class UpdatedHomePage extends StatefulWidget {
  const UpdatedHomePage({super.key});

  @override
  State<UpdatedHomePage> createState() => UpdatedHomePageState();
}

class UpdatedHomePageState extends State<UpdatedHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          ProfilePage(),
          AnimatedContainer(
            color: CustomColor.mainBrown,
            duration: Duration(milliseconds: 300),
            curve: Curves.fastEaseInToSlowEaseOut,
            child: Expanded(
                flex: 8,
                child: Container(
                  child: Text("hadeh"),
                )),
          )
        ],
      )),
    );
  }
}
