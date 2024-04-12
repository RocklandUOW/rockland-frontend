import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rockland/styles/colors.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

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
                child: Placeholder(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: const Center(
                      child: Text(
                        "Put a vector art or a video here",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 85, left: 40, top: 65, right: 40),
                child: Column(
                  children: [
                    Text(
                      "Rockland",
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Center(
                      child: Text(
                        "Welcome to Rockland! A onestop app for rock enthusiasts to explore, "
                        "collect, and connect with fellow rockhounds.",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     ElevatedButton(
                    //         onPressed: () {},
                    //         style: ElevatedButton.styleFrom(
                    //             minimumSize: const Size(250, 40)),
                    //         child: Text(
                    //           "Next",
                    //           style: TextStyle(color: CustomColor.mainBrown),
                    //         ))
                    //   ],
                    // )
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
