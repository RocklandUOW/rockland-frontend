import 'package:flutter/material.dart';
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
    widget.controller!.setListControllerPosition =
        setListControllerPosition;
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
    return Scaffold(
      backgroundColor: CustomColor.mainBrown,
      body: SafeArea(
          child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.builder(
                itemCount: 25,
                itemBuilder: (context, index) {
                  return Text("data");
                },
              ))),
    );
  }
}
