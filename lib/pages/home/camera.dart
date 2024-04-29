import 'package:flutter/material.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/screens/home.dart';
import 'package:rockland/styles/colors.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  PopUpContainerController controller = PopUpContainerController();

  @override
  void initState() {
    super.initState();
    HomeScreen.previousFragment.add(const CameraPage());
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double maxHeight = mediaQuery.size.height -
        mediaQuery.size.height * .08 -
        mediaQuery.padding.top;
    final double middleHeight = mediaQuery.size.height / 2 + 100;
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Container(
            color: CustomColor.mainBrown,
            child: Center(
              child: CommonButton(
                onPressed: () {
                  controller.showPopup();
                },
                buttonText: "Show popup",
              ),
            ),
          ),
          PopUpContainer(
            controller: controller,
            minHeight: 0,
            middleHeight: middleHeight,
            maxHeight: maxHeight,
            padding: EdgeInsets.only(left: 25, right: 25, top: 25),
            containerBgColor: CustomColor.mainBrown,
            listBgColor: CustomColor.mainBrown,
          ),
        ],
      )),
    );
  }
}

/*
Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: CommonButton(
                onPressed: () {
                  controller.showPopup();
                },
                buttonText: "Show popup lol",
                foregroundColor: Colors.black,
              ),
            ),
          )
 */
