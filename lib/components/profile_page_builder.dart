import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/pages/post-screen/post.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';

class ProfileBuilderController {
  late Function() moveHeaderUp;
  late Function() moveHeaderDown;
}

class ProfilePageBuilder extends StatefulWidget {
  final ProfileBuilderController? profileBuilderController;

  const ProfilePageBuilder({super.key, this.profileBuilderController});

  @override
  State<ProfilePageBuilder> createState() => _ProfilePageBuilderState();
}

class _ProfilePageBuilderState extends State<ProfilePageBuilder> {
  bool isProfilePage = true;
  bool collectionVisible = true;

  @override
  void initState() {
    super.initState();
    widget.profileBuilderController?.moveHeaderDown = moveHeaderDown;
    widget.profileBuilderController?.moveHeaderUp = moveHeaderUp;
  }

  void moveHeaderUp() {
    setState(() {
      isProfilePage = false;
      Future.delayed(const Duration(milliseconds: 250), () {
        collectionVisible = false;
      });
    });
  }

  void moveHeaderDown() {
    setState(() {
      collectionVisible = true;
      isProfilePage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double parentHeight = mediaQuery.size.height;
    final double parentWidth = mediaQuery.size.width;
    final double middleHeight = parentHeight / 2 + 90;

    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                height: 280,
                transform: Matrix4.identity()
                  ..translate(0.0, isProfilePage ? -30.0 : -50.0),
                color: CustomColor.fifthBrown,
                duration: Common.duration250,
                curve: Curves.ease,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("lib/images/profile_bg.png")
                                  as ImageProvider,
                              fit: BoxFit.cover),
                        ),
                        child: AnimatedOpacity(
                          opacity: isProfilePage ? 1.0 : 1.0,
                          duration: Common.duration250,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        top: 0,
                        right: 0,
                        bottom: 0,
                        left: 0,
                        child: Container(
                          color: Colors.black.withAlpha(80),
                        )),
                    // === WELCOME BACK CONTAINER ===
                    AnimatedContainer(
                      duration: Common.duration250,
                      transform: Matrix4.identity()
                        ..translate(0.0, isProfilePage ? 25.0 : 5.0),
                      alignment: Alignment.centerLeft,
                      curve: Curves.ease,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                AnimatedContainer(
                                  duration: Common.duration250,
                                  curve: Curves.ease,
                                  width: isProfilePage ? 80 : 50,
                                  height: isProfilePage ? 80 : 50,
                                  child: const CircleAvatar(
                                    child: Icon(
                                      Icons.person,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AnimatedContainer(
                                      duration: Common.duration300,
                                      transform: Matrix4.identity()
                                        ..translate(
                                            0.0, isProfilePage ? 5.0 : 0.0),
                                      alignment: Alignment.centerLeft,
                                      curve: Curves.ease,
                                      child: AnimatedOpacity(
                                        opacity: isProfilePage ? 0 : 1,
                                        duration: Common.duration100,
                                        child: const Text(
                                          "Welcome back,",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: Common.duration250,
                                      transform: Matrix4.identity()
                                        ..translate(
                                            0.0, isProfilePage ? -10.0 : 0.0),
                                      alignment: Alignment.centerLeft,
                                      curve: Curves.ease,
                                      child: AnimatedDefaultTextStyle(
                                          style: TextStyle(
                                              fontSize: isProfilePage ? 28 : 24,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Lato",
                                              color: Colors.white),
                                          duration: Common.duration150,
                                          child: const Text(
                                            "John Doe",
                                          )),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            AnimatedContainer(
                              duration: Common.duration300,
                              transform: Matrix4.identity()
                                ..translate(0.0, isProfilePage ? 0.0 : 0.0),
                              alignment: Alignment.centerLeft,
                              curve: Curves.ease,
                              child: AnimatedOpacity(
                                opacity: isProfilePage ? 1 : 0,
                                duration: Common.duration100,
                                child: CommonButton(
                                  onPressed: () {},
                                  isIcon: true,
                                  size: const Size(40, 40),
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  icon: const Icon(
                                    Icons.settings,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )),
          AnimatedContainer(
            duration: Common.duration250,
            transform: Matrix4.identity()
              ..translate(0.0, isProfilePage ? 0.0 : -50.0),
            curve: Curves.ease,
            child: PopUpContainer(
              minHeight: middleHeight + 10,
              middleHeight: middleHeight + 10,
              maxHeight: middleHeight + 10,
              enableDrag: false,
              enableDragIndicator: false,
              containerBgColor: CustomColor.mainBrown,
              listBgColor: CustomColor.sixthBrown,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Biography",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Welcome to my profile! Enjoy my collection of rocks I've found throughout my rock hunting journey.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Visibility(
                    visible: collectionVisible,
                    child: Container(
                      width: parentWidth,
                      color: CustomColor.brownMostRecent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 25, vertical: 20),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.collections_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Collection",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2, right: 2),
                            child: GridView.builder(
                              itemCount: 18,
                              itemBuilder: (context, index) {
                                if (index < 18 - 3) {
                                  return InkWell(
                                    onTap: () {
                                      Activity.startActivity(
                                          context, const PostPage());
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                        image: DecorationImage(
                                            image: AssetImage(
                                                    "lib/images/LogoUpscaled.png")
                                                as ImageProvider,
                                            fit: BoxFit.cover),
                                      ),
                                      height: 24,
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: EdgeInsets.all(55),
                                    child: CircularProgressIndicator(
                                      color: index == 18 - 2
                                          ? CustomColor.extremelyLightBrown
                                          : Colors.transparent,
                                    ),
                                  );
                                }
                              },
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 2,
                                      crossAxisSpacing: 2),
                              physics:
                                  const NeverScrollableScrollPhysics(), // to disable GridView's scrolling
                              shrinkWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          )
        ],
      )),
    );
  }
}
