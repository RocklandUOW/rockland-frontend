import 'package:flutter/material.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/components/gradient_text.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/pages/post-screen/post.dart';
import 'package:rockland/screens/home.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';

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
    final parentWidth = mediaQuery.size.width;

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
            containerBgColor: CustomColor.mainBrown,
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
                        height: 180,
                        decoration: BoxDecoration(
                            border: Border.all(
                                width: 1,
                                color: CustomColor.seventhBrown,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Text(
                          "Insert game moment",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                    Text("data"),
                  ],
                ),
              )
            ],
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
