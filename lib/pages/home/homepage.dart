import 'package:flutter/material.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/components/gradient_text.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/components/post_thumbnail.dart';
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
    final double middleHeight = mediaQuery.size.height / 2 + 150;
    final parentWidth = mediaQuery.size.width;
    final parentHeight = mediaQuery.size.height;

    return Scaffold(
      body: Stack(
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
            containerBgColor: CustomColor.mainBrown,
            listBgColor: CustomColor.mainBrown,
            shadowBgColor: Colors.transparent,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 25, right: 25, top: 15),
                child: Card(
                  color: CustomColor.fifthBrown,
                  surfaceTintColor: CustomColor.fifthBrown,
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GradientText(
                          text: "Daily rock facts",
                          gradient: LinearGradient(colors: [
                            CustomColor.orangeIsh,
                            CustomColor.aBitOrange,
                            CustomColor.lightYellow,
                          ]),
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Opal is a hydrated amorphous form of silica. Due to its amorphous property, it is classified as a mineraloid, unlike crystalline forms of silica, which are considered minerals. Read more...",
                          style: TextStyle(color: Colors.white),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                decoration: const BoxDecoration(
                    color: CustomColor.sixthBrown,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(25),
                      child: Container(
                        alignment: Alignment.center,
                        width: parentWidth,
                        height: 250,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1,
                                color: CustomColor.seventhBrown,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text(
                          "Game shortcut here",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Container(
                      width: parentWidth,
                      decoration: const BoxDecoration(
                          color: CustomColor.brownMostRecent,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              bottomLeft: Radius.circular(20))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 25, top: 30),
                            child: Text(
                              "Most recent posts",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                "Discover rocks recently found by other rockhounds",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              )),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 25, right: 25, top: 15, bottom: 30),
                              child: Row(
                                children: [
                                  const PostThumbnail(),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  const PostThumbnail(),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  const PostThumbnail(),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  const PostThumbnail(),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  const PostThumbnail(),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  const PostThumbnail(),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  const PostThumbnail(),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  const PostThumbnail(),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  const PostThumbnail(),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  const PostThumbnail(),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      children: [
                                        const Text(
                                          "View all",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        CommonButton(
                                          onPressed: () {},
                                          isIcon: true,
                                          icon: const Icon(
                                              Icons.arrow_right_rounded),
                                          foregroundColor: Colors.black,
                                          size: const Size(40, 40),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
