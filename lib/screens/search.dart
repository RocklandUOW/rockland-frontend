import 'package:flutter/material.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/components/post_thumbnail_discover.dart';
import 'package:rockland/pages/post-screen/post.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  ScrollController listViewController =
      ScrollController(initialScrollOffset: 0.0);
  bool isGridView = false;
  FocusNode textFieldFocusNode = FocusNode();

  Future<void> onRefresh() async {
    await Future.delayed(
      const Duration(milliseconds: 200),
    );
  }

  @override
  void initState() {
    super.initState();
    textFieldFocusNode.requestFocus();
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
          // RefreshIndicator(
          //     onRefresh: onRefresh,
          //     child: ListView.builder(
          //       controller: listViewController,
          //       itemCount: 1 + 2,
          //       itemBuilder: (context, index) {
          //         if (index == 0) {
          //           return Padding(
          //             padding: const EdgeInsets.only(top: 90),
          //             child: Container(
          //               width: parentWidth,
          //               color: Colors.white.withAlpha(50),
          //             ),
          //           );
          //         } else if (index < 1 + 2 - 1) {
          //           return const PostThumbnailDiscover();
          //         } else {
          //           return const Padding(
          //             padding: EdgeInsets.symmetric(vertical: 25),
          //             child: Center(
          //               child: SizedBox(
          //                 height: 18,
          //                 width: 18,
          //                 child: CircularProgressIndicator(
          //                   color: CustomColor.extremelyLightBrown,
          //                 ),
          //               ),
          //             ),
          //           );
          //         }
          //       },
          //     )),
          Container(
            decoration: const BoxDecoration(
                color: CustomColor.mainBrown,
                border: Border(bottom: BorderSide(color: Colors.white38))),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 15, right: 15, top: 20 + safeAreaPadding, bottom: 15),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => setState(() {
                            Activity.finishActivity(context);
                          }),
                      style:
                          IconButton.styleFrom(foregroundColor: Colors.white),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: CustomColor.fifthBrown,
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          TextField(
                            style: const TextStyle(color: Colors.white),
                            focusNode: textFieldFocusNode,
                            decoration: const InputDecoration(
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.transparent),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)))),
                          ),
                          const Padding(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
