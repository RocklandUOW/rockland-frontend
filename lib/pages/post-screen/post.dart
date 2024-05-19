import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rockland/components/alert_dialog.dart';
import 'package:rockland/components/camera_page_builder.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/components/post_buttons.dart';
import 'package:rockland/components/profile_page_builder.dart';
import 'package:rockland/components/rock_info.dart';
import 'package:rockland/pages/gmaps.dart';
import 'package:rockland/pages/home/profile.dart';
import 'package:rockland/screens/home.dart';
import 'package:rockland/screens/image.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/pages/post-screen/post_info.dart';
import 'package:rockland/pages/post-screen/post_comments.dart';
import 'package:rockland/pages/post-screen/post_identifications.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:rockland/utility/physics.dart';
import 'package:http/http.dart' as http;
import 'package:rockland/utility/strings.dart';
import 'package:rockland/utility/user_provider.dart';

class PostPage extends StatefulWidget {
  final Post post;
  final User? user;

  const PostPage({super.key, required this.post, this.user});

  @override
  State<PostPage> createState() => PostPageState();
}

class PostPageState extends State<PostPage> {
  final ScrollController scrollController = ScrollController();
  final Curve curveAnimation = Curves.easeInOut;
  final Duration scrollDuration = const Duration(milliseconds: 250);
  final PageController galleryController = PageController(initialPage: 0);
  PopUpContainerController commentsController = PopUpContainerController();
  PopUpContainerController verificationController = PopUpContainerController();

  int activePage = 0;
  int activePageGallery = 0;
  List<Widget> images = [];

  User user = User();
  User currentUser = User();
  bool isLoading = true;
  bool isRockLoading = true;
  bool rockHasError = false;
  bool hasError = false;
  late Error internalErr;
  late Error internalRockErr;
  late Rock rock;

  bool isPostLiked = false;

  late Post thisPost;

  // final List<Widget> pages = [
  //   const PostInfoPage(),
  //   const PostCommentPage(),
  //   const PostIdentificationsPage(),
  // ];

  // dialogs
  late DismissableAlertDialog resultDialog;
  late DismissableAlertDialog deleteDialog;
  late DismissableAlertDialog loadingDialog;

  @override
  void initState() {
    super.initState();

    thisPost = widget.post;

    // get rock info
    getRockInfo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = context.read<UserProvider>();
      currentUser = userState.user;
      // set user
      if (widget.user == null) {
        getUser();
      } else {
        isLoading = false;
        user = widget.user!;
      }
      getThisPost();
    });

    // set images
    for (dynamic imageLink in widget.post.pictureUrl) {
      images.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: imageLink,
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
      ));
    }

    resultDialog =
        DismissableAlertDialog(context: context, child: const Text(""));
    resultDialog.setOkButton(TextButton(
        onPressed: () => resultDialog.dismiss(), child: const Text("OK")));

    loadingDialog = LoadingDialog.construct(context);

    deleteDialog = DismissableAlertDialog(
        context: context,
        child: const Text("Are you sure you want to delete this post?"));
    deleteDialog.setCancelButton(TextButton(
        onPressed: () => deleteDialog.dismiss(), child: const Text("No")));
    deleteDialog.setOkButton(TextButton(
        onPressed: () async {
          deleteDialog.dismiss();
          loadingDialog.show();
          await deletePost();
          refresh();
        },
        child: const Text("Yes")));
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void getRockInfo() async {
    String identifiedRock = widget.post.rocktype;
    setState(() {
      isRockLoading = true;
    });
    try {
      final req = await http.post(
        Uri.parse(
          "https://rockland-app-service.onrender.com/get_rock_data_by_name/?name=$identifiedRock",
        ),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      ).catchError((e) {
        return http.Response(
            jsonEncode(
              <String, String>{"detail": e.toString()},
            ),
            999);
      });

      if (req.statusCode == 200) {
        setState(() {
          rock = Rock.fromJson(jsonDecode(req.body));
          isRockLoading = false;
        });
      } else if (req.statusCode == 999) {
        throw internalErr = Error(
            errorCode: req.statusCode,
            description: ConnectionStrings.connectionErrString);
      } else {
        throw internalErr = Error(
            errorCode: req.statusCode,
            description: ConnectionStrings.unknownErrorString);
      }
    } catch (e) {
      setState(() {
        isRockLoading = false;
        rockHasError = false;
        if (e is Error) {
          print((e as Error).errorCode);
          print((e as Error).description);
        } else {
          print(e.toString());
        }
        // to display to the user.
        // error = ErrorBuilder.build(internalErr.errorCode);
      });
    }
  }

  Future<void> getUser() async {
    const url = "https://rockland-app-service.onrender.com/get_account_by_id/";
    isLoading = true;
    try {
      http.Response response;
      try {
        response = await http.post(Uri.parse(url),
            headers: <String, String>{"Content-Type": "application/json"},
            body: jsonEncode(<String, String>{"id": widget.post.userId}));
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> userDetails = jsonDecode(response.body);
        setState(() {
          user = User.fromJson(userDetails);
          isLoading = false;
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
        if (e is Error) {
          print((e as Error).errorCode);
          print((e as Error).description);
        } else {
          print(e.toString());
        }
        // to display to the user.
        // error = ErrorBuilder.build(internalErr.errorCode);
      });
    }
  }

  void refresh() {
    setState(() {
      hasError = false;
      isPostLiked = false;
    });
    getThisPost();
  }

  Future<void> getThisPost() async {
    const url = "https://rockland-app-service.onrender.com/get_post_by_id/";
    isLoading = true;
    try {
      http.Response response;
      try {
        response = await http.post(Uri.parse(url),
            headers: <String, String>{"Content-Type": "application/json"},
            body: jsonEncode(<String, String>{"id": widget.post.id}));
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> updatedPost = jsonDecode(response.body);
        setState(() {
          thisPost = Post.fromJson(updatedPost);
          print(thisPost.liked);
          if (thisPost.liked.contains(user.id)) {
            isPostLiked = true;
          }
          isLoading = false;
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
        if (e is Error) {
          print((e as Error).errorCode);
          print((e as Error).description);
        } else {
          print(e.toString());
        }
        // to display to the user.
        // error = ErrorBuilder.build(internalErr.errorCode);
      });
    }
  }

  Future<void> likeUnlikePost(User user, bool liked) async {
    if (isLoading) return;
    print("invoked");
    isLoading = true;
    String url;
    if (!liked) {
      url =
          "https://rockland-app-service.onrender.com/add_account_to_post_liked/";
    } else {
      url =
          "https://rockland-app-service.onrender.com/remove_account_from_post_liked/";
    }

    try {
      http.Response response;
      try {
        response = await http.put(
          Uri.parse(url),
          headers: <String, String>{"Content-Type": "application/json"},
          body: jsonEncode(
            <String, String>{"post_id": widget.post.id, "user_id": user.id},
          ),
        );
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        print(response.body);
        setState(() {
          isLoading = false;
          refresh();
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
        print(e.toString());
        // to display to the user.
        // error = ErrorBuilder.build(internalErr.errorCode);
      });
    }
  }

  Future<void> deletePost() async {
    print("called");
    if (isLoading) return;
    print("called again");
    isLoading = true;
    const url = "https://rockland-app-service.onrender.com/delete_post/";
    try {
      http.Response response;
      try {
        response = await http.delete(
          Uri.parse(url),
          headers: <String, String>{"Content-Type": "application/json"},
          body: jsonEncode(
            <String, String>{
              "id": widget.post.id,
            },
          ),
        );
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
          loadingDialog.dismiss();
          resultDialog.setChild(const Text("Post was deleted successfully"));
        });
        await resultDialog.show();
        // Activity.finishActivity(context);
        // context.read<UserProvider>().refresh();

        // Navigator.of(context).pushAndRemoveUntil(
        //     MaterialPageRoute(builder: (context) => const HomeScreen()),
        //     (Route<dynamic> route) => false);
        Activity.startActivityAndRemoveHistory(context, const HomeScreen());
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
        print(e.toString());
        // to display to the user.
        // error = ErrorBuilder.build(internalErr.errorCode);
      });
    }
  }

  void changePage(bool advance) {
    setState(() {
      if (advance && activePageGallery < images.length - 1) {
        activePageGallery += 1;
      } else if (!advance && activePageGallery > 0) {
        activePageGallery -= 1;
      }
      galleryController.animateToPage(
        activePageGallery,
        duration: Common.duration300,
        curve: Curves.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double safeAreaPadding = mediaQuery.padding.top;
    final double parentWidth = mediaQuery.size.width;
    final double parentHeight = mediaQuery.size.height;
    final double middleHeight = parentHeight / 2 + 100;
    final double maxHeight = parentHeight - safeAreaPadding;

    return Consumer<UserProvider>(
      builder: (context, value, child) {
        currentUser = value.user;
        return Scaffold(
          backgroundColor: CustomColor.mainBrown,
          body: Stack(
            children: [
              Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: CustomColor.mainBrown,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 15,
                        right: 0,
                        top: 20 + safeAreaPadding,
                        bottom: 5,
                      ),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () =>
                                      Activity.finishActivity(context),
                                  style: IconButton.styleFrom(
                                      foregroundColor: Colors.white),
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  )),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: AnimatedSize(
                                  duration: Common.duration300,
                                  curve: Curves.ease,
                                  child: Text(
                                    isLoading
                                        ? ""
                                        : "Post by ${user.firstName} ${user.lastName}",
                                    maxLines: 1,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 15,
                            child: Visibility(
                                visible: currentUser.id == user.id &&
                                    currentUser.id != "",
                                child: IconButton(
                                  onPressed: () {
                                    if (currentUser.id != "") {
                                      deleteDialog.show();
                                    }
                                  },
                                  style: IconButton.styleFrom(
                                      foregroundColor: Colors.white),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        children: [
                          Container(
                            color: CustomColor.mainBrown,
                            child: Row(children: [
                              GestureDetector(
                                onTap: () => Activity.startActivity(
                                  context,
                                  ProfilePageBuilder(
                                    isFragment: false,
                                    user: user,
                                  ),
                                ),
                                child: Container(
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 30),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Container(
                                            clipBehavior: Clip.hardEdge,
                                            decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20))),
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
                                                      size: 20,
                                                    ),
                                                  ),
                                                  AnimatedOpacity(
                                                    opacity:
                                                        user.profilePictureUrl ==
                                                                ""
                                                            ? 0
                                                            : 1,
                                                    duration:
                                                        Common.duration300,
                                                    child: CachedNetworkImage(
                                                      imageUrl: user
                                                                  .profilePictureUrl ==
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
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        AnimatedSize(
                                          duration: Common.duration300,
                                          curve: Curves.ease,
                                          child: Text(
                                            "${user.firstName} ${user.lastName}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(children: [
                                  Text('20 May 2024',
                                      style: TextStyle(
                                          color: Colors.white.withAlpha(90))),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text('·',
                                      style: TextStyle(
                                          color: Colors.white.withAlpha(90))),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text('09.17',
                                      style: TextStyle(
                                          color: Colors.white.withAlpha(90))),
                                ]),
                              )
                            ]),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: parentWidth,
                                height: parentWidth - 30,
                                child: PageView.builder(
                                  physics: const CustomPageViewScrollPhysics(),
                                  controller: galleryController,
                                  onPageChanged: (int page) {
                                    setState(() {
                                      activePageGallery = page;
                                    });
                                  },
                                  itemCount: images.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () => Activity.startActivity(
                                        context,
                                        ViewImageExtended(
                                          images: thisPost.pictureUrl,
                                          user: user,
                                        ),
                                      ),
                                      child: images[index],
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                left: 0,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: AnimatedOpacity(
                                    opacity: activePageGallery > 0 ? 1 : 0,
                                    duration: Common.duration100,
                                    child: AnimatedContainer(
                                      duration: Common.duration100,
                                      curve: Curves.ease,
                                      transform: Transform.translate(
                                        offset: Offset(
                                            activePageGallery > 0 ? 0 : -5, 0),
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
                              ),
                              Positioned(
                                right: 0,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: AnimatedOpacity(
                                    opacity:
                                        activePageGallery < images.length - 1
                                            ? 1
                                            : 0,
                                    duration: Common.duration100,
                                    child: AnimatedContainer(
                                      duration: Common.duration100,
                                      curve: Curves.ease,
                                      transform: Transform.translate(
                                        offset: Offset(
                                            activePageGallery <
                                                    images.length - 1
                                                ? 0
                                                : 5,
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
                                ),
                              )
                            ],
                          ),
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
                                    width: activePageGallery == index ? 15 : 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: activePageGallery == index
                                          ? Colors.white
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: CustomColor.fifthBrown,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    PostButtons(
                                      parentState: this,
                                      onPress: () {
                                        scrollController.animateTo(
                                          scrollController
                                              .position.maxScrollExtent,
                                          duration: Common.duration300,
                                          curve: Curves.ease,
                                        );
                                      },
                                      icon: Icons.info_outline,
                                    ),
                                    PostButtons(
                                      parentState: this,
                                      onPress: () {
                                        if (value.user.id == "") {
                                          resultDialog.setChild(const Text(
                                            "Sign in to favorite this post",
                                          ));
                                          resultDialog.show();
                                        } else if (!isLoading) {
                                          likeUnlikePost(user, isPostLiked);
                                        }
                                      },
                                      icon: isPostLiked
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border,
                                      color: isPostLiked
                                          ? Colors.redAccent
                                          : Colors.white,
                                    ),
                                    PostButtons(
                                        parentState: this,
                                        onPress: () {
                                          commentsController.showPopup();
                                        },
                                        icon: Icons.comment),
                                    PostButtons(
                                      parentState: this,
                                      onPress: () {
                                        verificationController.showPopup();
                                      },
                                      icon: Icons.verified_user,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            width: parentWidth,
                            decoration: const BoxDecoration(
                              color: CustomColor.sixthBrown,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(
                                      left: 30, right: 30, top: 35),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30),
                                  child: Text(
                                    thisPost.description,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(25),
                                  child: GestureDetector(
                                    onTap: () => Activity.startActivity(
                                      context,
                                      RockInformation(
                                        identifiedRock: rock,
                                        isFragment: false,
                                      ),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: parentWidth,
                                      decoration: const BoxDecoration(
                                        color: CustomColor.brownMostRecent,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 20,
                                        ),
                                        child: IgnorePointer(
                                          ignoring: isRockLoading,
                                          child: Row(
                                            mainAxisAlignment: isRockLoading
                                                ? MainAxisAlignment.center
                                                : MainAxisAlignment.start,
                                            children: isRockLoading
                                                ? [
                                                    const Wrap(
                                                      alignment:
                                                          WrapAlignment.center,
                                                      runAlignment:
                                                          WrapAlignment.center,
                                                      children: [
                                                        SizedBox(
                                                          width: 30,
                                                          height: 30,
                                                          child:
                                                              CircularProgressIndicator(
                                                            color: CustomColor
                                                                .extremelyLightBrown,
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ]
                                                : [
                                                    Container(
                                                      width: 75,
                                                      height: 75,
                                                      clipBehavior:
                                                          Clip.hardEdge,
                                                      decoration: const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          10))),
                                                      child: IgnorePointer(
                                                        child:
                                                            CachedNetworkImage(
                                                          fit: BoxFit.cover,
                                                          imageUrl: rock.rock[
                                                                  "images"][0]
                                                              ["link"],
                                                          progressIndicatorBuilder:
                                                              (
                                                            context,
                                                            url,
                                                            downloadProgress,
                                                          ) {
                                                            return Wrap(
                                                              alignment:
                                                                  WrapAlignment
                                                                      .center,
                                                              runAlignment:
                                                                  WrapAlignment
                                                                      .center,
                                                              children: [
                                                                SizedBox(
                                                                  width: 30,
                                                                  height: 30,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    color: CustomColor
                                                                        .extremelyLightBrown,
                                                                    value: downloadProgress
                                                                        .progress,
                                                                  ),
                                                                )
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            rock.rock["name"],
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 5),
                                                          const Text(
                                                            "Tap this card to learn more about this rock",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const CircleAvatar(
                                                      child: Icon(
                                                        size: 35,
                                                        Icons
                                                            .keyboard_arrow_right_sharp,
                                                        color: CustomColor
                                                            .mainBrown,
                                                      ),
                                                    )
                                                  ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 25,
                                    right: 25,
                                    bottom: 30,
                                  ),
                                  child: Container(
                                    width: parentWidth,
                                    decoration: const BoxDecoration(
                                      color: CustomColor.brownMostRecent,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                    child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 20,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const CircleAvatar(
                                              child: Icon(
                                                Icons.place,
                                                color: CustomColor.mainBrown,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            const Expanded(
                                                child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Keiraville",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  "NSW, 2500",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            )),
                                            GestureDetector(
                                              onTap: () =>
                                                  Activity.startActivity(
                                                      context,
                                                      GMapsPage(
                                                        posts: [widget.post],
                                                      )),
                                              child: Container(
                                                width: 100,
                                                height: 100,
                                                clipBehavior: Clip.hardEdge,
                                                decoration: const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: IgnorePointer(
                                                  child: GMapsPage(
                                                    posts: [widget.post],
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),

              // // COMMENT POPUP CONTAINER
              PostCommentPage(parentState: this),

              // VERIFICATION POPUP CONTAINER
              PostIdentificationsPage(parentState: this)
            ],
          ),
        );
      },
    );
  }
}
