import 'package:flutter/material.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/pages/gmaps.dart';
import 'package:rockland/screens/account/login.dart';
import 'package:rockland/screens/account/register.dart';
import 'package:rockland/styles/colors.dart';

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

  void handleButtonPress(BuildContext context, Widget activity) {
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => activity),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: CustomColor.mainBrown,
            child: SafeArea(
                child: Center(
              child: Column(
                children: [
                  const Expanded(
                      child: SizedBox(
                    height: 25,
                  )),
                  Column(
                    children: [
                      Placeholder(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 250,
                          child: const Center(
                            child: Text(
                              "Put a vector art or a video here",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      const Text(
                        "Ready to join in? 🌟",
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(
                            top: 15, bottom: 25, left: 25, right: 25),
                        child: Text(
                          "Register now to gain full access to Rockland's features, "
                          "or sign in if you already have an account.",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CommonButton(
                            onPressed: () => handleButtonPress(
                                context, const RegisterAccount()),
                            buttonText: "Register",
                            textColor: Colors.white,
                            foregroundColor: CustomColor.mainBrown,
                            size: const Size(150, 40),
                            gradient: const LinearGradient(colors: [
                              CustomColor.buttonOrange,
                              CustomColor.buttonYellow
                            ]),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          CommonButton(
                            onPressed: () => handleButtonPress(
                                context, const LoginAccount()),
                            buttonText: "Sign in",
                            textColor: Colors.white,
                            foregroundColor: Colors.white,
                            size: const Size(150, 40),
                            isoutlined: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  Expanded(
                      child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: CommonButton(
                          onPressed: () =>
                              handleButtonPress(context, const GMapsPage()),
                          isText: true,
                          buttonText: "Skip for now. Take me to the app >",
                          size:
                              Size(MediaQuery.of(context).size.width - 75, 40),
                          textColor: Colors.white,
                        ),
                      )
                    ],
                  )),
                ],
              ),
            ))));
  }
}
