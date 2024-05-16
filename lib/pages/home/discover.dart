import 'package:flutter/material.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/components/post_thumbnail_discover.dart';
import 'package:rockland/pages/post-screen/post.dart';
import 'package:rockland/screens/search.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';

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
  bool isGridView = false;

  Future<void> onRefresh() async {
    await Future.delayed(
      const Duration(milliseconds: 200),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.controller!.getListController = getListController;
    widget.controller!.setListControllerPosition = setListControllerPosition;
  }

  ScrollController getListController() {
    return listViewController;
  }

  void setListControllerPosition(double offset) {
    listViewController.animateTo(offset,
        duration: Common.duration250, curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safeAreaPadding = mediaQuery.padding.top;

    double parentWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: CustomColor.mainBrown,
      body: Stack(
        children: [
          RawGestureDetector(
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
                    ? ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 90),
                            child: Container(
                              height: 1,
                              width: parentWidth,
                              color: Colors.white.withAlpha(50),
                            ),
                          ),
                          GridView.builder(
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
                                  padding: const EdgeInsets.all(55),
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
                          )
                        ],
                      )
                    : ListView.builder(
                        controller: listViewController,
                        itemCount: 10 + 2,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 90),
                              child: Container(
                                width: parentWidth,
                                color: Colors.white.withAlpha(50),
                              ),
                            );
                          } else if (index < 10 + 2 - 1) {
                            return const PostThumbnailDiscover();
                          } else {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 25),
                              child: Center(
                                child: SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    color: CustomColor.extremelyLightBrown,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      )),
          ),
          Container(
            decoration: const BoxDecoration(
                color: CustomColor.mainBrown,
                border: Border(bottom: BorderSide(color: Colors.white38))),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 15, right: 15, top: 20 + safeAreaPadding, bottom: 15),
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
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
