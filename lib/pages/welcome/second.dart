import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rockland/styles/colors.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animController;

  @override
  void initState() {
    animController = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CustomColor.mainBrown,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 25,
                    right: 25,
                    top: 100,
                  ),
                  child: Lottie.asset(
                    "lib/images/lottie/Social.json",
                    controller: animController,
                    onLoaded: (composition) {
                      animController.duration = composition.duration;
                      animController.repeat();
                    },
                  ),
                ),
              ),
              const Padding(
                padding:
                    EdgeInsets.only(bottom: 150, left: 40, top: 100, right: 40),
                child: Column(
                  children: [
                    Text(
                      "Explore, collect, share! 👥",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: Text(
                        "Explore and find rocks in your rock hunting journey, add them to your digital collection, and share them to the world.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
