import 'package:flutter/material.dart';
import 'package:rockland/pages/homepage/dashboard.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/physics.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController pageController = PageController(initialPage: 0);

  int activePage = 0;

  List<Widget> pages = [
    const DashboardPage(),
    const DashboardPage(),
  ];

  void _handleTabButtonPress(int toPage) {
    setState(() {
      activePage = toPage;
      pageController.animateToPage(toPage,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.mainBrown,
      body: SafeArea(
          child: Center(
              child: Column(
        children: [
          Container(
            color: CustomColor.mainBrown,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        "Rockland",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22),
                      ),
                      Text(
                        "Welcome back, John!",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
                color: CustomColor.mainBrown,
                border: Border(
                    bottom: BorderSide(width: 0.5, color: Colors.white30))),
            child: Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 1.5,
                                  color: activePage == 0
                                      ? Colors.white
                                      : Colors.transparent))),
                      child: TextButton(
                          onPressed: () => _handleTabButtonPress(0),
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0))),
                          child: const Text(
                            "Dashboard",
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                  ),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  width: 1.5,
                                  color: activePage == 1
                                      ? Colors.white
                                      : Colors.transparent))),
                      child: TextButton(
                          onPressed: () => _handleTabButtonPress(1),
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0))),
                          child: const Text(
                            "Posts",
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
              child: PageView.builder(
            controller: pageController,
            onPageChanged: (value) => setState(() {
              activePage = value;
            }),
            physics: const CustomPageViewScrollPhysics(),
            itemCount: pages.length,
            itemBuilder: (BuildContext context, int index) {
              return pages[index % pages.length];
            },
          ))
        ],
      ))),
    );
  }
}
