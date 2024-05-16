import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/components/gradient_text.dart';
import 'package:rockland/components/information_row.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/components/post_thumbnail.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:rockland/utility/physics.dart';
import 'package:rockland/utility/strings.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;

class WhenIdentified extends StatefulWidget {
  final Rock identifiedRock;

  const WhenIdentified({super.key, required this.identifiedRock});

  @override
  State<WhenIdentified> createState() => _WhenIdentifiedState();
}

class _WhenIdentifiedState extends State<WhenIdentified> {
  // name
  late String rockName;

  // description
  late List description;
  late int randomIndex;
  late String randomDescription;

  // wikipedia link
  late String wikipedia;

  // rock information
  late List infoField;

  // rock photo gallery
  final PageController galleryController = PageController(initialPage: 0);
  int activePage = 0;
  List<Widget> images = [];
  late List<dynamic> imagesData;

  @override
  void initState() {
    super.initState();
    rockName = widget.identifiedRock.rock["name"];
    description = widget.identifiedRock.rock["description"];
    randomIndex = Random().nextInt(100) % description.length;
    randomDescription = description[randomIndex];
    wikipedia = widget.identifiedRock.rock["wikipedia"];

    infoField = widget.identifiedRock.rock.keys.toList();
    infoField.remove("identifier");
    infoField.remove("description");
    infoField.remove("name");
    infoField.remove("wikipedia");
    infoField.remove("images");

    imagesData = widget.identifiedRock.rock["images"];

    for (dynamic imageData in imagesData) {
      imageData = RockImages.fromJson(imageData);
      images.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: imageData.link,
              progressIndicatorBuilder: (
                context,
                url,
                downloadProgress,
              ) {
                return Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        color: CustomColor.extremelyLightBrown,
                        value: downloadProgress.progress,
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ),
      );
    }
  }

  void changePage(bool advance) {
    setState(() {
      if (advance && activePage < images.length - 1) {
        activePage += 1;
      } else if (!advance && activePage > 0) {
        activePage -= 1;
      }
      galleryController.animateToPage(
        activePage,
        duration: Common.duration300,
        curve: Curves.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double paddingTop = mediaQuery.padding.top;
    final double parentWidth = mediaQuery.size.width;
    final double parentHeight = mediaQuery.size.height;
    final double maxHeight = parentHeight - parentHeight * .08 - paddingTop;
    final double middleHeight = parentHeight / 2;

    return Container(
      color: CustomColor.fifthBrown,
      width: parentWidth,
      height: parentHeight - parentHeight * .08,
      child: Stack(
        children: [
          Positioned(
              top: paddingTop,
              left: 0,
              right: 0,
              bottom: middleHeight,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 25, right: 25, top: 25, bottom: 10),
                    child: Text(
                      rockName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Flexible(
                      child: Column(
                    children: [
                      Flexible(
                          child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: AnimatedOpacity(
                              opacity: activePage > 0 ? 1 : 0,
                              duration: Common.duration100,
                              child: AnimatedContainer(
                                duration: Common.duration100,
                                curve: Curves.ease,
                                transform: Transform.translate(
                                  offset: Offset(activePage > 0 ? 0 : -5, 0),
                                ).transform,
                                child: IconButton(
                                    onPressed: () => changePage(false),
                                    style: IconButton.styleFrom(
                                        foregroundColor: Colors.white10),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_left,
                                      size: 30,
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ),
                          Flexible(
                              child: PageView.builder(
                            physics: const CustomPageViewScrollPhysics(),
                            controller: galleryController,
                            onPageChanged: (int page) {
                              setState(() {
                                activePage = page;
                              });
                            },
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return images[index];
                            },
                          )),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: AnimatedOpacity(
                              opacity: activePage < images.length - 1 ? 1 : 0,
                              duration: Common.duration100,
                              child: AnimatedContainer(
                                duration: Common.duration100,
                                curve: Curves.ease,
                                transform: Transform.translate(
                                  offset: Offset(
                                      activePage < images.length - 1 ? 0 : 5,
                                      0),
                                ).transform,
                                child: IconButton(
                                    onPressed: () => changePage(true),
                                    style: IconButton.styleFrom(
                                        foregroundColor: Colors.white10),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_right,
                                      size: 30,
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          )
                        ],
                      )),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List<Widget>.generate(
                            images.length,
                            (index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOutSine,
                                width: activePage == index ? 15 : 5,
                                height: 5,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: activePage == index
                                        ? Colors.white
                                        : Colors.grey[600]),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ))
                ],
              )),
          PopUpContainer(
            minHeight: middleHeight,
            middleHeight: middleHeight,
            maxHeight: maxHeight,
            listBgColor: CustomColor.mainBrown,
            containerBgColor: CustomColor.mainBrown,
            enableHideOnTapShadow: false,
            shadowBgColor: Colors.transparent,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: Card(
                  color: CustomColor.fifthBrown,
                  surfaceTintColor: CustomColor.fifthBrown,
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const GradientText(
                          text: "Rock information",
                          gradient: LinearGradient(colors: [
                            CustomColor.orangeIsh,
                            CustomColor.aBitOrange,
                            CustomColor.lightYellow,
                          ]),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        // capitalize is a custom String extension defined in common.dart
                        ...infoField.map((key) => RockInfoRow.makeRow(
                            (key as String).replaceAll("_", " ").capitalize(),
                            widget.identifiedRock.rock[key])),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                width: parentWidth,
                decoration: const BoxDecoration(
                    color: CustomColor.sixthBrown,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 30, right: 30, top: 35),
                      child: Text(
                        "Description",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        randomDescription,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => launchUrlString(wikipedia),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white10),
                            child: const Text(
                              "Read more on Wikipedia >",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
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
                              "Recent posts",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              child: Text(
                                "Recent posts about this rock",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              )),
                          const SizedBox(
                            height: 10,
                          ),
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
                      height: 30,
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class CameraPageBuilder {
  static List<Widget> whenLoading() {
    return [
      Expanded(child: Container()),
      const Text(
        "Identifying",
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(
        height: 15,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Text(
          RockIdentificationStrings.identifying,
          style: CommonStyles.commonTextStyle,
        ),
      ),
      const SizedBox(
        height: 15,
      ),
      const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          color: CustomColor.extremelyLightBrown,
          strokeWidth: 3,
        ),
      ),
      Expanded(child: Container()),
    ];
  }

  static List<Widget> whenFirstOpened() {
    return [
      Expanded(child: Container()),
      Text(
        "Opening camera",
        style: CommonStyles.commonTextStyle,
      ),
      const SizedBox(
        height: 15,
      ),
      const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          color: CustomColor.extremelyLightBrown,
          strokeWidth: 3,
        ),
      ),
      Expanded(child: Container())
    ];
  }

  static List<Widget> whenNotIdentified(Function takePhoto) {
    return [
      Expanded(child: Container()),
      const Text(
        "We couldn't find a match 🙏",
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(
        height: 15,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
        ),
        child: Text(
          RockIdentificationStrings.notIdentified,
          style: CommonStyles.commonTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(
        height: 15,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
              onPressed: () => takePhoto(),
              icon: const Icon(
                Icons.camera_alt,
                color: CustomColor.fifthBrown,
              ),
              label: Text(
                CommonStrings.tryAgain,
                style: CommonStyles.mainBrownText,
              )),
          const SizedBox(
            width: 15,
          ),
          ElevatedButton.icon(
              onPressed: () async =>
                  await launchUrlString("mailto:${CommonStrings.email}"),
              icon: const Icon(
                Icons.email,
                color: CustomColor.fifthBrown,
              ),
              label: Text(
                CommonStrings.contactUs,
                style: CommonStyles.mainBrownText,
              )),
        ],
      ),
      Expanded(child: Container()),
    ];
  }
}
