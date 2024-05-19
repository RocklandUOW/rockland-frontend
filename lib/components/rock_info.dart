import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/components/gradient_text.dart';
import 'package:rockland/components/information_row.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/components/post_thumbnail.dart';
import 'package:rockland/screens/image.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:rockland/utility/physics.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;
import 'package:visibility_detector/visibility_detector.dart';

class RockInformation extends StatefulWidget {
  final Rock identifiedRock;
  final bool isFragment;

  const RockInformation({
    super.key,
    required this.identifiedRock,
    this.isFragment = true,
  });

  @override
  State<RockInformation> createState() => _RockInformationState();
}

class _RockInformationState extends State<RockInformation> {
  ScrollController mostRecentController = ScrollController();
  PopUpContainerController popUpController = PopUpContainerController();

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

  //posts
  bool isGridView = false;
  bool isLoading = false;
  bool hasMorePosts = true;
  bool hasError = false;
  bool requestNext = false;
  int currentPostPage = 1;
  late Error error;
  late Error internalErr;
  List<Post> posts = [];

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

    for (int i = 0; i < imagesData.length; i++) {
      RockImages imageData = RockImages.fromJson(imagesData[i]);
      Widget child;
      if (imageData.link.contains("http")) {
        child = GestureDetector(
          onTap: () => Activity.startActivity(
              context,
              ViewImageExtended(
                images: imagesData,
                page: i,
              )),
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
        );
      } else {
        child = GestureDetector(
          onTap: () => Activity.startActivity(
              context,
              ViewImageExtended(
                images: imagesData,
                page: i,
              )),
          child: Image.file(
            File(imageData.link),
            fit: BoxFit.cover,
          ),
        );
      }
      images.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            child: child,
          ),
        ),
      );
    }
  }

  loadPostsWorker() async {
    while (true) {
      print("background task lol");
      if (!requestNext) {
        break;
      }
      await getPosts();
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> getPosts() async {
    if (isLoading || !hasMorePosts) return;
    isLoading = true;

    const limit = 10;
    final url =
        "https://rockland-app-service.onrender.com/search_posts_rocktype/?rocktype=${widget.identifiedRock.name}&page_num=$currentPostPage&page_size=$limit";
    try {
      http.Response response;
      try {
        response = await http.get(Uri.parse(url));
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        final List postsNextPage = jsonDecode(response.body);
        setState(() {
          isLoading = false;
          currentPostPage += 1;
          posts.addAll(postsNextPage.map((post) {
            return Post.fromJson(post);
          }).toList());
          if (postsNextPage.length < limit) {
            hasMorePosts = false;
          }
        });
      } else {
        throw internalErr = Error(
          errorCode: response.statusCode,
          description:
              "A server error has occured on the discover service. Status code is as stated.",
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = false;
        hasMorePosts = false;
        print(e.toString());
        // to display to the user.
        // error = ErrorBuilder.build(internalErr.errorCode);
      });
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

  Widget builder(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double paddingTop = mediaQuery.padding.top;
    final double parentWidth = mediaQuery.size.width;
    final double parentHeight = mediaQuery.size.height;
    final double navbarHeight = parentHeight * .08;
    final double maxHeight = parentHeight - navbarHeight - paddingTop;
    double containerHeight, middleHeight;
    if (widget.isFragment) {
      containerHeight = parentHeight - navbarHeight;
      middleHeight = parentHeight / 2;
    } else {
      containerHeight = parentHeight;
      middleHeight = parentHeight / 2 + navbarHeight;
    }

    final Widget child = Container(
      color: CustomColor.fifthBrown,
      width: parentWidth,
      height: containerHeight,
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
            controller: popUpController,
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
                            controller: mostRecentController,
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 25, right: 25, top: 15, bottom: 30),
                              child: Row(
                                children: [
                                  ...posts.map((post) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 15),
                                      child: PostThumbnail(
                                        post: post,
                                      ),
                                    );
                                  }),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  hasMorePosts
                                      ? VisibilityDetector(
                                          key: const Key("loadingindicator4"),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 150, vertical: 50),
                                            child: SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: CircularProgressIndicator(
                                                  color: CustomColor
                                                      .extremelyLightBrown),
                                            ),
                                          ),
                                          onVisibilityChanged: (info) {
                                            setState(() {
                                              if (info.visibleFraction > 0 &&
                                                  posts.length < 10) {
                                                requestNext = true;
                                                loadPostsWorker();
                                              } else {
                                                popUpController.animateToBottom(
                                                  Common.duration300,
                                                  Curves.ease,
                                                );
                                                requestNext = false;
                                                hasMorePosts = false;
                                              }
                                            });
                                          },
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Column(
                                            children: [
                                              const Text(
                                                "View all",
                                                style: TextStyle(
                                                    color: Colors.white),
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
                                        ),
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
    if (widget.isFragment) {
      return child;
    } else {
      return Scaffold(
        backgroundColor: CustomColor.mainBrown,
        body: child,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}
