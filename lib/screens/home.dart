import 'package:flutter/material.dart';
import 'package:rockland/components/navbar_button.dart';
import 'package:rockland/pages/home/camera.dart';
import 'package:rockland/pages/home/discover.dart';
import 'package:rockland/pages/home/homepage.dart';
import 'package:rockland/pages/home/notification.dart';
import 'package:rockland/pages/home/profile.dart';
import 'package:rockland/styles/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController pageController = PageController(initialPage: 0);

  int activePage = 0;

  final List<Widget> pages = [
    const HomePage(),
    const DiscoverPage(),
    const CameraPage(),
    const NotificationPage(),
    const ProfilePage(),
  ];

  void _onNavbarButtonPressed(int pageIndex) {
    setState(() {
      activePage = pageIndex;
      pageController.jumpToPage(pageIndex);
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
            color: CustomColor.mainBrown,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
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
                      activePage == 1 ? Icons.map : Icons.map_outlined,
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
