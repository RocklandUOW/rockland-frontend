import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/components/gradient_text.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/components/post_thumbnail.dart';
import 'package:rockland/components/profile_page_builder.dart';
import 'package:rockland/pages/home/profile.dart';
import 'package:rockland/screens/game/loading.dart';
import 'package:rockland/screens/home.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:http/http.dart' as http;
import 'package:rockland/utility/user_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomePageController {
  late Function() hidePopup;
  late Function() getAnimationDuration;
  late Function() getPopUpController;
}

class HomePage extends StatefulWidget {
  final HomePageController? controller;
  final HomeScreenState? parentState;
  final UserProvider? provider;

  const HomePage({super.key, this.controller, this.parentState, this.provider});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  PopUpContainerController controller = PopUpContainerController();
  ProfileBuilderController pbcontroller = ProfileBuilderController();
  ScrollController mostRecentController = ScrollController();
  int animationDuration = 250;

  bool isLoading = false;
  bool hasMorePosts = true;
  bool hasError = false;
  bool requestNext = false;
  bool isGameFirstOpen = true;
  int currentPostPage = 1;
  late Error error;
  late Error internalErr;
  List<Post> posts = [];

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
        "https://rockland-app-service.onrender.com/get_all_posts_by_latest/?page_num=$currentPostPage&page_size=$limit";
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

  void refresh() {
    setState(() {
      isLoading = false;
      hasError = false;
      hasMorePosts = true;
      requestNext = true;
      currentPostPage = 1;
      posts.clear();
    });
    getPosts().then((value) => controller.animateToBottom(
          Common.duration300,
          Curves.ease,
        ));
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

    return VisibilityDetector(
      key: const Key("homepagevisibilitydetect"),
      child: Consumer<UserProvider>(
        builder: (context, value, child) => Scaffold(
          body: Stack(
            children: [
              ProfilePageBuilder(
                profileBuilderController: pbcontroller,
                user: value.user,
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                        GestureDetector(
                          onTap: () async {
                            await Activity.startActivityForResult(
                              context,
                              GameLoadingScreen(isFirstOpen: isGameFirstOpen),
                            );
                            isGameFirstOpen = false;
                          },
                          child: Padding(
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
                              child: const Padding(
                                padding: EdgeInsets.all(25),
                                child: Image(
                                  fit: BoxFit.cover,
                                  image: AssetImage(
                                    "lib/images/games_banner.png",
                                  ),
                                ),
                              ),
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
                                controller: mostRecentController,
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 25, right: 25, top: 15, bottom: 30),
                                  child: Row(
                                    children: [
                                      ...posts.map((post) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(right: 15),
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
                                              key: const Key(
                                                  "loadingindicator3"),
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 150,
                                                    vertical: 50),
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
                                                  if (info.visibleFraction >
                                                          0 &&
                                                      posts.length < 10) {
                                                    requestNext = true;
                                                    loadPostsWorker();
                                                  } else {
                                                    controller.animateToBottom(
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
                                                    onPressed: () => widget
                                                        .parentState
                                                        ?.onNavbarButtonPressed(
                                                            1),
                                                    isIcon: true,
                                                    icon: const Icon(Icons
                                                        .arrow_right_rounded),
                                                    foregroundColor:
                                                        Colors.black,
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
                          height: 25,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      onVisibilityChanged: (info) {
        // if (info.visibleFraction == 1) {
        //   refresh();
        // }
      },
    );
  }
}
