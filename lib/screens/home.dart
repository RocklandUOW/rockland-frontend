import 'package:flutter/material.dart';
import 'package:rockland/components/alert_dialog.dart';
import 'package:rockland/components/navbar_button.dart';
import 'package:rockland/pages/home/camera.dart';
import 'package:rockland/pages/home/discover.dart';
import 'package:rockland/pages/home/homepage.dart';
import 'package:rockland/pages/home/notification.dart';
import 'package:rockland/pages/home/profile.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/common.dart';

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
  late DismissableAlertDialog loading;

  int activePage = 0;

  final List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    // set controller to page 0 to show the subtitle beneath the
    // navbar icon
    pages.addAll([
      HomePage(
        controller: homeController,
      ),
      DiscoverPage(
        controller: discoverController,
      ),
      const CameraPage(),
      NotificationPage(
        parentState: this,
      ),
      const ProfilePage()
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onNavbarButtonPressed(0);
    });
    loading = LoadingDialog.construct(context);
  }

  void _onNavbarButtonPressed(int pageIndex) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: PageView.builder(
            physics: const NeverScrollableScrollPhysics(),
            controller: pageController,
            onPageChanged: (int value) {
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
            height: MediaQuery.of(context).size.height * .08, // NAVBAR HEIGHT
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
                    onPressed: () => _onNavbarButtonPressed(0),
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
                    onPressed: () => _onNavbarButtonPressed(1),
                  ),
                  CustomNavbarButton(
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                    ),
                    buttonIndex: 2,
                    subtitle: "Camera",
                    pageController: pageController,
                    onPressed: () => _onNavbarButtonPressed(2),
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
                    onPressed: () => _onNavbarButtonPressed(3),
                  ),
                  CustomNavbarButton(
                    icon: Icon(
                      activePage == 4 ? Icons.person : Icons.person_outline,
                      color: Colors.white,
                    ),
                    buttonIndex: 4,
                    subtitle: "Profile",
                    pageController: pageController,
                    onPressed: () => _onNavbarButtonPressed(4),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
