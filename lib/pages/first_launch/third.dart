import 'package:flutter/material.dart';
import 'package:rockland/pages/gmaps.dart';
import 'package:rockland/styles/colors.dart';

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: CustomColor.mainBrown,
            child: SafeArea(
                child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    "This is the third page",
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              // builder: (context) => const NavigationTest()),
                              builder: (context) => const GMapsPage()),
                        );
                      },
                      style: ButtonStyle(
                          overlayColor:
                              MaterialStateProperty.all<Color>(Colors.black12)),
                      child: const Text(
                        "Ok! Take me to Google Maps~",
                        style: TextStyle(color: CustomColor.mainBrown),
                      ))
                ],
              ),
            ))));
  }
}
