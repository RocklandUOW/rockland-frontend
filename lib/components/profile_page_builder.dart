// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/components/post_thumbnail_discover_grid.dart';
import 'package:rockland/screens/settings.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:http/http.dart' as http;
import 'package:rockland/utility/user_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ProfileBuilderController {
  late Function() moveHeaderUp;
  late Function() moveHeaderDown;
}

class ProfilePageBuilder extends StatefulWidget {
  final ProfileBuilderController? profileBuilderController;
  final bool isFragment;
  final User? user;
  final UserProvider? provider;

  const ProfilePageBuilder({
    super.key,
    this.profileBuilderController,
    this.isFragment = true,
    this.user,
    this.provider,
  });

  @override
  State<ProfilePageBuilder> createState() => _ProfilePageBuilderState();
}

class _ProfilePageBuilderState extends State<ProfilePageBuilder> {
  bool isProfilePage = true;
  bool collectionVisible = true;
  late User user;

  // posts
  bool isGridView = false;
  bool isLoading = false;
  bool hasMorePosts = true;
  bool hasError = false;
  bool requestNext = false;
  int currentPostPage = 1;
  late Error error;
  late Error internalErr;
  List<Post> posts = [];
  List<dynamic> finalPosts = [];

  @override
  void initState() {
    super.initState();
    widget.profileBuilderController?.moveHeaderDown = moveHeaderDown;
    widget.profileBuilderController?.moveHeaderUp = moveHeaderUp;
    if (widget.user != null) {
      user = widget.user!;
      print("widget.user!.id");
      print(widget.user!.id);
    } else {
      user = User(
          id: "663b8a943231c2bdd950335e",
          firstName: "Kadal",
          lastName: "Sispek",
          aboutMe: "Hello world");
    }
    // final provider = context.read<UserProvider>();
    getPosts();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
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

  Future<void> getPosts() async {
    if (isLoading || !hasMorePosts) return;
    isLoading = true;

    const limit = 30;
    final url =
        "https://rockland-app-service.onrender.com/get_posts_by_user_id/?page_num=$currentPostPage&page_size=$limit";
    try {
      http.Response response;
      try {
        response = await http.post(
          Uri.parse(url),
          headers: <String, String>{"Content-Type": "application/json"},
          body: jsonEncode(
            <String, String>{"id": user.id},
          ),
        );
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

          finalPosts = posts;

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
        if (e is Error) {
          print(e.errorCode);
          print(e.description);
        } else {
          print(e.toString());
        }
        // to display to the user.
        // error = ErrorBuilder.build(internalErr.errorCode);
      });
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double parentHeight = mediaQuery.size.height;
    final double parentWidth = mediaQuery.size.width;
    double middleHeight;
    if (widget.isFragment) {
      middleHeight = parentHeight / 2 + 90;
    } else {
      middleHeight = (parentHeight / 2 + 90) + parentHeight * .08;
    }

    // for gridview
    var row = (posts.length / 3).ceil(); // -> get the row count
    var multiplier = row * 3;
    var toAdd = multiplier - posts.length;
    if (toAdd == 3) {
      toAdd = 0;
    }

    // about me and posts
    String aboutme;

    final provider = Provider.of<UserProvider>(context);

    if (user.id == provider.user.id) {
      finalPosts = provider.posts;
      if (provider.user.aboutMe == "")
        aboutme = "${provider.user.firstName} has not written anything yet.";
      else
        aboutme = provider.user.aboutMe;
    } else {
      finalPosts = posts;
      if (user.aboutMe == "")
        aboutme = "${user.firstName} has not written anything yet.";
      else
        aboutme = user.aboutMe;
    }

    return Consumer<UserProvider>(
      builder: (context, value, child) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedContainer(
                    height: 280,
                    transform: Matrix4.identity()
                      ..translate(0.0, isProfilePage ? 0.0 : -15.0),
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
                                filter:
                                    ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.0)),
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
                          ),
                        ),
                        // === WELCOME BACK CONTAINER ===
                        AnimatedContainer(
                          duration: Common.duration250,
                          transform: Matrix4.identity()
                            ..translate(0.0, isProfilePage ? 25.0 : 10.0),
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
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(100),
                                        ),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: CircleAvatar(
                                        child: Stack(
                                          children: [
                                            const Positioned(
                                              left: 0,
                                              right: 0,
                                              top: 0,
                                              bottom: 0,
                                              child: Icon(
                                                Icons.person,
                                                size: 30,
                                              ),
                                            ),
                                            Positioned(
                                                left: 0,
                                                right: 0,
                                                top: 0,
                                                bottom: 0,
                                                child: Container(
                                                  child: AnimatedOpacity(
                                                    opacity: widget.isFragment
                                                        ? value.user.profilePictureUrl ==
                                                                ""
                                                            ? 0
                                                            : 1
                                                        : user.profilePictureUrl ==
                                                                ""
                                                            ? 0
                                                            : 1,
                                                    duration:
                                                        Common.duration300,
                                                    child: CachedNetworkImage(
                                                      imageUrl: widget
                                                              .isFragment
                                                          ? value.user.profilePictureUrl ==
                                                                  ""
                                                              ? "https://static.vecteezy.com/system/resources/thumbnails/004/511/281/small/default-avatar-photo-placeholder-profile-picture-vector.jpg"
                                                              : value.user
                                                                  .profilePictureUrl
                                                          : user.profilePictureUrl ==
                                                                  ""
                                                              ? "https://static.vecteezy.com/system/resources/thumbnails/004/511/281/small/default-avatar-photo-placeholder-profile-picture-vector.jpg"
                                                              : user
                                                                  .profilePictureUrl,
                                                      fit: BoxFit.cover,
                                                      progressIndicatorBuilder:
                                                          (
                                                        context,
                                                        url,
                                                        downloadProgress,
                                                      ) {
                                                        return CircularProgressIndicator(
                                                          color: CustomColor
                                                              .extremelyLightBrown,
                                                          value:
                                                              downloadProgress
                                                                  .progress,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        AnimatedContainer(
                                          duration: Common.duration250,
                                          transform: Matrix4.identity()
                                            ..translate(0.0,
                                                isProfilePage ? -10.0 : 0.0),
                                          alignment: Alignment.centerLeft,
                                          curve: Curves.ease,
                                          child: AnimatedDefaultTextStyle(
                                            style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Lato",
                                                color: Colors.white),
                                            duration: Common.duration150,
                                            child: widget.isFragment
                                                ? Text(
                                                    "${value.user.firstName} ${value.user.lastName}")
                                                : user.id == value.user.id
                                                    ? Text(
                                                        "${value.user.firstName} ${value.user.lastName}",
                                                      )
                                                    : Text(
                                                        "${user.firstName} ${user.lastName}",
                                                      ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                Visibility(
                                    visible: widget.isFragment
                                        ? true
                                        : user.id == value.user.id,
                                    child: AnimatedContainer(
                                      duration: Common.duration300,
                                      transform: Matrix4.identity()
                                        ..translate(
                                            0.0, isProfilePage ? 0.0 : 0.0),
                                      alignment: Alignment.centerLeft,
                                      curve: Curves.ease,
                                      child: AnimatedOpacity(
                                        opacity: isProfilePage ? 1 : 0,
                                        duration: Common.duration100,
                                        child: CommonButton(
                                          onPressed: () {
                                            Activity.startActivity(context,
                                                const SettingsScreen());
                                          },
                                          isIcon: true,
                                          size: const Size(40, 40),
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          icon: const Icon(
                                            Icons.settings,
                                          ),
                                        ),
                                      ),
                                    ))
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
                    Visibility(
                      visible: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
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
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              aboutme,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                        visible: collectionVisible,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minHeight: middleHeight, minWidth: parentWidth),
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                                color: CustomColor.brownMostRecent),
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
                                  padding:
                                      const EdgeInsets.only(left: 2, right: 2),
                                  child: GridView.builder(
                                    // 3 is for the last bottom 3,
                                    // toadd is to add remaining columns in a row
                                    itemCount: widget.isFragment
                                        ? value.posts.isEmpty
                                            ? 6
                                            : value.posts.length
                                        : posts.isEmpty
                                            ? 6
                                            : posts.length + toAdd + 3,
                                    itemBuilder: (context, index) {
                                      // get the proper post list to populate the gridview
                                      final populatePosts = widget.isFragment
                                          ? value.posts
                                          : posts;

                                      // populate the gridview
                                      if (populatePosts.isEmpty) {
                                        return index == 4
                                            ? Text("Nothing here yet",
                                                textAlign: TextAlign.center,
                                                style: CommonStyles
                                                    .commonTextStyle)
                                            : const SizedBox();
                                      } else {
                                        if (index < populatePosts.length) {
                                          return GridViewThumbnail(
                                              post: populatePosts[index]);
                                        } else {
                                          int bottomMiddle =
                                              populatePosts.length +
                                                  toAdd +
                                                  3 -
                                                  2;
                                          return Padding(
                                            padding: const EdgeInsets.all(55),
                                            child: hasMorePosts &&
                                                        user.id !=
                                                            value.user.id ||
                                                    value.isLoading
                                                ? VisibilityDetector(
                                                    key: const Key(
                                                        "loadingindicator1"),
                                                    child:
                                                        CircularProgressIndicator(
                                                      // 3 is for the last bottom 3,
                                                      // toadd is to add remaining columns in a row
                                                      // 2 is the middle to show the loading indicator
                                                      color: index ==
                                                              bottomMiddle
                                                          ? CustomColor
                                                              .extremelyLightBrown
                                                          : Colors.transparent,
                                                    ),
                                                    onVisibilityChanged:
                                                        (info) {
                                                      if (info.visibleFraction >
                                                          0) {
                                                        requestNext = true;
                                                        // loadPostsWorker();
                                                      } else {
                                                        requestNext = false;
                                                      }
                                                    },
                                                  )
                                                : Wrap(
                                                    alignment:
                                                        WrapAlignment.center,
                                                    runAlignment:
                                                        WrapAlignment.center,
                                                    children: [
                                                      Container(
                                                        width: 5,
                                                        height: 5,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: index ==
                                                                  bottomMiddle
                                                              ? CustomColor
                                                                  .brownMostRecent
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(
                                                            Radius.circular(20),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                          );
                                        }
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
                          ),
                        ))
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
