import 'package:flutter/material.dart';
import 'package:rockland/components/post_thumbnail_discover.dart';
import 'package:rockland/components/textfield.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/common.dart';

class DiscoverPageController {
  late Function() getListController;
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
    double parentWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: CustomColor.mainBrown,
      body: SafeArea(
          child: Stack(
        children: [
          RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.builder(
                itemCount: 10 + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 90),
                      child: Container(
                        height: 1,
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
          const TextField(
            decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.white30),
                focusColor: Colors.black,
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white))),
          ),
        ],
      )),
    );
  }
}
