import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rockland/components/alert_dialog.dart';
import 'package:rockland/components/navbar_button.dart';
import 'package:rockland/pages/home/camera.dart';
import 'package:rockland/pages/home/discover.dart';
import 'package:rockland/pages/home/homepage.dart';
import 'package:rockland/pages/home/notification.dart';
import 'package:rockland/pages/home/profile.dart';
import 'package:rockland/screens/newpost.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/user_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static List<Widget> previousFragment = [];
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final PageController pageController = PageController(initialPage: 0);
  final HomePageController homeController = HomePageController();
  final DiscoverPageController discoverController = DiscoverPageController();
  final CameraPageController cameraController = CameraPageController();
  late DismissableAlertDialog loading;
  final UserProvider provider = UserProvider();

  int activePage = 0;
  final List<Widget> pages = [];

  // for new post -> from camera
  List<File> postImages = [];

  DateTime? currentBackPressTime;
  bool canPopNow = false;
  int requiredSeconds = 2;

  @override
  void initState() {
    super.initState();
    // set controller to page 0 to show the subtitle beneath the
    // navbar icon
    // provider.setUserId("663b8a943231c2bdd950335e");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.read<UserProvider>().setUserId("663b8a943231c2bdd950335e");
      // context.read<UserProvider>().refresh();
      // context.read<UserProvider>().setUserId("66486058128efa5aade1ccd0");
    });
    pages.addAll([
      HomePage(
        controller: homeController,
        parentState: this,
        provider: provider,
      ),
      DiscoverPage(
        controller: discoverController,
      ),
      CameraPage(
        controller: cameraController,
        parentState: this,
      ),
      NotificationPage(
        parentState: this,
      ),
      const ProfilePage()
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onNavbarButtonPressed(0);
    });
    loading = LoadingDialog.construct(context);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void onNavbarButtonPressed(int pageIndex) {
    setState(() {
      activePage = pageIndex;
      List<Widget> history = HomeScreen.previousFragment;
      history.add(pages[pageIndex]);
      if (history.length > 2) {
        HomeScreen.previousFragment = history.sublist(history.length - 2);
      }
      print(HomeScreen.previousFragment);
      if (pageIndex == 4 && HomeScreen.previousFragment[0] is HomePage) {
        homeController.hidePopup();
        Future.delayed(
            Duration(milliseconds: homeController.getAnimationDuration()), () {
          pageController.jumpToPage(pageIndex);
        });
      } else {
        pageController.jumpToPage(pageIndex);
      }
    });
  }

  void onPopInvoked(bool didPop) {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Press back one more time to exit the app");
      // Ok, let user exit app on the next back press
      setState(() {
        canPopNow = true;
      });
      Future.delayed(
        Duration(seconds: requiredSeconds),
        () {
          // Disable pop invoke and close the toast after 2s timeout
          setState(() {
            canPopNow = false;
            currentBackPressTime = null;
          });
          Fluttertoast.cancel();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: SystemUiOverlay.values);
        
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double parentHeight = mediaQuery.size.height;
    final double navbarHeight = parentHeight * .08;

    return Consumer<UserProvider>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: CustomColor.mainBrown,
        floatingActionButton: value.user.id == ""
            ? null
            : Stack(
                children: [
                  Positioned(
                      right: 14,
                      bottom: navbarHeight + 14,
                      child: FloatingActionButton(
                        backgroundColor: CustomColor.extremelyLightBrown,
                        tooltip: 'Make a new post',
                        onPressed: () {
                          Activity.startActivity(
                            context,
                            NewPostScreen(
                              initialPhotos: postImages,
                            ),
                          );
                        },
                        child: Transform.translate(
                          offset: const Offset(1.5, -1.5),
                          child: const RotationTransition(
                            turns: AlwaysStoppedAnimation(-45 / 360),
                            child: Icon(Icons.send,
                                color: CustomColor.mainBrown, size: 28),
                          ),
                        ),
                      ))
                ],
              ),
        body: PopScope(
            canPop: canPopNow,
            onPopInvoked: onPopInvoked,
            child: Column(
              children: [
                Expanded(
                    child: PageView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: pageController,
                  onPageChanged: (int value) {
                    WidgetsBinding.instance.focusManager.primaryFocus
                        ?.unfocus();
                    setState(() {
                      activePage = value;
                    });
                  },
                  itemCount: pages.length,
                  itemBuilder: (BuildContext context, int index) {
                    return pages[index % pages.length];
                  },
                )),
                Container(
                  height:
                      MediaQuery.of(context).size.height * .08, // NAVBAR HEIGHT
                  color: CustomColor.mainBrown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomNavbarButton(
                          icon: Icon(
                            activePage == 0 ? Icons.home : Icons.home_outlined,
                            color: Colors.white,
                          ),
                          buttonIndex: 0,
                          subtitle: "Home",
                          pageController: pageController,
                          onPressed: () => onNavbarButtonPressed(0),
                        ),
                        CustomNavbarButton(
                          icon: Icon(
                            activePage == 1
                                ? Icons.people_alt
                                : Icons.people_alt_outlined,
                            color: Colors.white,
                          ),
                          buttonIndex: 1,
                          subtitle: "Discover",
                          pageController: pageController,
                          onPressed: () {
                            onNavbarButtonPressed(1);
                            // trycatch to prevent app crash when function is not
                            // initialised yet
                            try {
                              final scrollController =
                                  discoverController.getListController();
                              if (scrollController.hasClients) {
                                discoverController
                                    .setListControllerPosition(0.0);
                              }
                            } catch (_) {}
                          },
                        ),
                        CustomNavbarButton(
                          icon: Icon(
                            activePage == 2
                                ? Icons.camera_alt
                                : Icons.camera_alt_outlined,
                            color: Colors.white,
                          ),
                          buttonIndex: 2,
                          subtitle: "Identify",
                          pageController: pageController,
                          onPressed: () async {
                            onNavbarButtonPressed(2);
                            // trycatch to prevent app crash when function is not
                            // initialised yet
                            try {
                              if (activePage == 2) {
                                // await to prevent disposed setstate error
                                await cameraController.takePhoto!();
                              }
                            } catch (_) {}
                          },
                        ),
                        CustomNavbarButton(
                          icon: Icon(
                            activePage == 3
                                ? Icons.notifications
                                : Icons.notifications_outlined,
                            color: Colors.white,
                          ),
                          buttonIndex: 3,
                          subtitle: "Notification",
                          pageController: pageController,
                          onPressed: () => onNavbarButtonPressed(3),
                        ),
                        CustomNavbarButton(
                          icon: Icon(
                            activePage == 4
                                ? Icons.person
                                : Icons.person_outline,
                            color: Colors.white,
                          ),
                          buttonIndex: 4,
                          subtitle: "Profile",
                          pageController: pageController,
                          onPressed: () => onNavbarButtonPressed(4),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
