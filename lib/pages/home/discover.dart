import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/components/post_thumbnail_discover.dart';
import 'package:rockland/components/post_thumbnail_discover_grid.dart';
import 'package:rockland/pages/gmaps.dart';
import 'package:rockland/screens/search.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';
import 'package:http/http.dart' as http;
import 'package:rockland/utility/model.dart';
import 'package:visibility_detector/visibility_detector.dart';

class DiscoverPageController {
  late ScrollController Function() getListController;
  late Function(double offset) setListControllerPosition;
}

class DiscoverPage extends StatefulWidget {
  final DiscoverPageController? controller;

  const DiscoverPage({super.key, this.controller});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  ScrollController listViewController =
      ScrollController(initialScrollOffset: 0.0);
  ScrollController gridViewListController =
      ScrollController(initialScrollOffset: 0.0);

  bool isGridView = true;
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
    widget.controller!.getListController = getListController;
    widget.controller!.setListControllerPosition = setListControllerPosition;

    listViewController.addListener(() {
      if (listViewController.position.maxScrollExtent ==
          listViewController.offset) {
        print("reached bottom");
        getPosts();
      }
    });

    gridViewListController.addListener(
      () {
        if (gridViewListController.position.maxScrollExtent ==
            gridViewListController.offset) {
          print("reached bottom");
          getPosts();
        }
      },
    );
    getPosts();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
    requestNext = false;
  }

  ScrollController getListController() {
    return listViewController;
  }

  void setListControllerPosition(double offset) {
    listViewController.animateTo(offset,
        duration: Common.duration250, curve: Curves.ease);
  }

  Future<void> onRefresh() async {
    setState(() {
      isLoading = false;
      hasMorePosts = true;
      currentPostPage = 1;
      posts.clear();
    });
    getPosts();
  }

  Future<void> getPosts() async {
    if (isLoading || !hasMorePosts) return;
    isLoading = true;

    const limit = 30;
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
    final safeAreaPadding = mediaQuery.padding.top;

    // for gridview
    var row = (posts.length / 3).ceil(); // -> get the row count
    var multiplier = row * 3;
    var toAdd = multiplier - posts.length;
    if (toAdd == 3) {
      toAdd = 0;
    }

    double parentWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: CustomColor.mainBrown,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: CustomColor.mainBrown,
              // border: Border(bottom: BorderSide(color: Colors.white38)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 15, right: 15, top: 20 + safeAreaPadding),
              child: Row(
                children: [
                  Flexible(
                      child: Container(
                    decoration: const BoxDecoration(
                        color: CustomColor.fifthBrown,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: RawGestureDetector(
                      gestures: {
                        AllowMultipleVerticalDragGestureRecognizer:
                            GestureRecognizerFactoryWithHandlers<
                                AllowMultipleVerticalDragGestureRecognizer>(
                          () => AllowMultipleVerticalDragGestureRecognizer(),
                          (AllowMultipleVerticalDragGestureRecognizer
                              instance) {
                            instance.onStart = (details) {
                              Activity.startActivity(
                                  context, const SearchScreen());
                            };
                          },
                        )
                      },
                      behavior: HitTestBehavior.translucent,
                      child: const IgnorePointer(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            TextField(
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      top: 13, bottom: 13, left: 50, right: 20),
                                  hintText: "Search",
                                  hintStyle: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white38),
                                  focusColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20)))),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 15),
                              child: Icon(
                                Icons.search,
                                color: Colors.white38,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: CustomColor.fifthBrown,
                        border: Border.all(color: Colors.transparent),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(100))),
                    child: IconButton(
                        onPressed: () => setState(() {
                              isGridView = !isGridView;
                            }),
                        style:
                            IconButton.styleFrom(foregroundColor: Colors.white),
                        icon: Icon(
                          isGridView
                              ? Icons.grid_view_rounded
                              : Icons.view_list,
                          color: Colors.white,
                        )),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: CustomColor.fifthBrown,
                        border: Border.all(color: Colors.transparent),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(100))),
                    child: IconButton(
                        onPressed: () => Activity.startActivity(
                            context,
                            const GMapsPage(
                              isDiscover: true,
                            )),
                        style:
                            IconButton.styleFrom(foregroundColor: Colors.white),
                        icon: const Icon(
                          Icons.map,
                          color: Colors.white,
                        )),
                  )
                ],
              ),
            ),
          ),
          Flexible(
              child: RawGestureDetector(
            gestures: {
              AllowMultipleVerticalDragGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                      AllowMultipleVerticalDragGestureRecognizer>(
                () => AllowMultipleVerticalDragGestureRecognizer(),
                (AllowMultipleVerticalDragGestureRecognizer instance) {
                  instance.onStart =
                      (details) => FocusScope.of(context).unfocus();
                },
              )
            },
            behavior: HitTestBehavior.translucent,
            child: RefreshIndicator(
                onRefresh: onRefresh,
                child: isGridView
                    ? Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Container(
                          width: parentWidth,
                          decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: Colors.white.withAlpha(50)))),
                          child: SingleChildScrollView(
                            child: GridView.builder(
                              // 3 is for the last bottom 3,
                              // toadd is to add remaining columns in a row
                              itemCount: posts.length + toAdd + 3,
                              itemBuilder: (context, index) {
                                if (index < posts.length) {
                                  return GridViewThumbnail(post: posts[index]);
                                } else {
                                  int bottomMiddle =
                                      posts.length + toAdd + 3 - 2;
                                  return Padding(
                                    padding: const EdgeInsets.all(55),
                                    child: hasMorePosts
                                        ? VisibilityDetector(
                                            key: const Key("loadingindicator1"),
                                            child: CircularProgressIndicator(
                                              // 3 is for the last bottom 3,
                                              // toadd is to add remaining columns in a row
                                              // 2 is the middle to show the loading indicator
                                              color: index == bottomMiddle
                                                  ? CustomColor
                                                      .extremelyLightBrown
                                                  : Colors.transparent,
                                            ),
                                            onVisibilityChanged: (info) {
                                              if (info.visibleFraction > 0) {
                                                requestNext = true;
                                                loadPostsWorker();
                                              } else {
                                                requestNext = false;
                                              }
                                            },
                                          )
                                        : Wrap(
                                            alignment: WrapAlignment.center,
                                            runAlignment: WrapAlignment.center,
                                            children: [
                                              Container(
                                                width: 5,
                                                height: 5,
                                                decoration: BoxDecoration(
                                                  color: index == bottomMiddle
                                                      ? CustomColor
                                                          .brownMostRecent
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                    Radius.circular(20),
                                                  ),
                                                ),
                                              )
                                            ],
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
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: SingleChildScrollView(
                          controller: listViewController,
                          child: Column(
                            children: [
                              Container(
                                width: parentWidth,
                                height: 1,
                                color: Colors.white.withAlpha(50),
                              ),
                              ...posts.map((post) {
                                return PostThumbnailDiscover(post: post);
                              }),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 25),
                                child: Center(
                                  child: hasMorePosts
                                      ? VisibilityDetector(
                                          key: const Key("loadingindicator2"),
                                          child: const SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              color: CustomColor
                                                  .extremelyLightBrown,
                                            ),
                                          ),
                                          onVisibilityChanged: (info) {
                                            if (info.visibleFraction > 0) {
                                              requestNext = true;
                                              loadPostsWorker();
                                            } else {
                                              requestNext = false;
                                            }
                                          },
                                        )
                                      : Container(
                                          width: 5,
                                          height: 5,
                                          decoration: const BoxDecoration(
                                            color: CustomColor.brownMostRecent,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                          ),
                                        ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
          ))
        ],
      ),
    );
  }
}
