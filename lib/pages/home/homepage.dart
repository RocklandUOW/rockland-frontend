import 'package:flutter/material.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/components/profile_page_builder.dart';
import 'package:rockland/pages/home/profile.dart';
import 'package:rockland/screens/home.dart';
import 'package:rockland/styles/colors.dart';

class HomePageController {
  late Function() hidePopup;
  late Function() getAnimationDuration;
  late Function() getPopUpController;
}

class HomePage extends StatefulWidget {
  final HomePageController? controller;

  const HomePage({super.key, this.controller});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  PopUpContainerController controller = PopUpContainerController();
  ProfileBuilderController pbcontroller = ProfileBuilderController();
  int animationDuration = 250;

  @override
  void initState() {
    super.initState();
    widget.controller?.hidePopup = hidePopup;
    widget.controller?.getAnimationDuration = () => animationDuration;
    widget.controller?.getPopUpController = () => controller;
    HomeScreen.previousFragment.add(const HomePage());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.showPopup();
      pbcontroller.moveHeaderUp();
      print(HomeScreen.previousFragment);
    });
  }

  void hidePopup() {
    controller.hidePopup();
    pbcontroller.moveHeaderDown();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double middleHeight = mediaQuery.size.height / 2 + 200;
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          ProfilePageBuilder(
            profileBuilderController: pbcontroller,
          ),
          PopUpContainer(
            enableDrag: false,
            enableHideOnTapShadow: false,
            controller: controller,
            animationDuration: animationDuration,
            minHeight: HomeScreen.previousFragment[0] is ProfilePage
                ? 0
                : middleHeight - 0.1,
            middleHeight: middleHeight,
            maxHeight: middleHeight,
            padding: const EdgeInsets.only(top: 15),
            containerBgColor: CustomColor.mainBrown,
            shadowBgColor: Colors.transparent,
          ),
        ],
      )),
    );
  }
}
