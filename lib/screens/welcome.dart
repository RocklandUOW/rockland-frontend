import 'package:flutter/material.dart';
import 'package:rockland/pages/welcome/first.dart';
import 'package:rockland/pages/welcome/second.dart';
import 'package:rockland/pages/welcome/third.dart';
import 'package:rockland/utility/physics.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController pageController = PageController(initialPage: 0);

  int activePage = 0;

  final List<Widget> pages = [
    const FirstPage(),
    const SecondPage(),
    const ThirdPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            physics: const CustomPageViewScrollPhysics(),
            controller: pageController,
            onPageChanged: (int index) {
              setState(() {
                activePage = index;
              });
            },
            itemCount: pages.length,
            itemBuilder: (BuildContext context, int index) {
              return pages[index % pages.length];
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                pages.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutSine,
                    width: activePage == index ? 30 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: activePage == index ? Colors.white : Colors.grey[600]),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
