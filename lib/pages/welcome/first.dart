import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rockland/styles/colors.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage>
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
                    "lib/images/lottie/Rockland.json",
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
                      "Rockland 🪨",
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Text(
                        "Hi there, rockhound! Rockland is a onestop app for rock enthusiasts to explore, "
                        "collect, and connect with fellow rockhounds.",
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
