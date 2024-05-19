import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/screens/account/login.dart';
import 'package:rockland/screens/account/register.dart';
import 'package:rockland/screens/home.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';

class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage>
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
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 250,
                        child: Lottie.asset(
                          "lib/images/lottie/Check.json",
                          controller: animController,
                          onLoaded: (composition) {
                            animController.duration = composition.duration;
                            animController.forward();
                          },
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
                            onPressed: () => Activity.startActivity(
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
                            onPressed: () => Activity.startActivity(
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
                          onPressed: () {
                            Activity.startActivityAndRemoveHistory(
                              context,
                              const HomeScreen(),
                            );
                          },
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
