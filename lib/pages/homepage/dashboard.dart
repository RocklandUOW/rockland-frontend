import 'package:flutter/material.dart';
import 'package:rockland/pages/home/profile.dart';
import 'package:rockland/styles/colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
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
