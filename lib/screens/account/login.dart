import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/components/textfield.dart';
import 'package:rockland/styles/colors.dart';

class LoginAccount extends StatefulWidget {
  const LoginAccount({super.key});

  @override
  State<LoginAccount> createState() => _LoginAccountState();
}

class _LoginAccountState extends State<LoginAccount> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.mainBrown,
      body: SafeArea(
          child: Center(
        child: Column(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
              ),
              child: ListView(
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 25,
                      ),
                      SizedBox(
                        height: 250,
                        child: Stack(
                          children: [
                            const Placeholder(),
                            CommonButton(
                              onPressed: () {},
                              size: const Size(40, 40),
                              isIcon: true,
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                              ),
                              backgroundColor: Colors.white,
                            ),
                            const Positioned.fill(
                                child: Align(
                              alignment: Alignment.center,
                              child: Text("Put bg art here",
                                  style: TextStyle(color: Colors.white38)),
                            ))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      CommonTextField(
                          controller: emailController,
                          hintText: "Email",
                          fontWeight: FontWeight.normal,
                          icon: const Icon(
                            Icons.email,
                            color: Colors.white,
                          )),
                      const SizedBox(
                        height: 25,
                      ),
                      CommonTextField(
                          controller: passwordController,
                          hintText: "Password",
                          obscureText: true,
                          fontWeight: FontWeight.normal,
                          icon: const Icon(
                            Icons.key,
                            color: Colors.white,
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              text: 'Forgot your password? ',
                              style: TextStyle(height: 1.5),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Reset it',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      CommonButton(
                        onPressed: () {
                          print(emailController.text);
                          print(passwordController.text);
                        },
                        buttonText: "Sign in",
                        textColor: Colors.white,
                        gradient: const LinearGradient(colors: [
                          CustomColor.buttonOrange,
                          CustomColor.buttonYellow
                        ]),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.white,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "or",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      CommonButton(
                        onPressed: () {},
                        buttonText: "Create an account",
                        isoutlined: true,
                        textColor: Colors.white,
                        foregroundColor: Colors.white,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  )
                ],
              ),
            )),
            Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      text: 'By continuing, you agree to the ',
                      style: TextStyle(height: 1.5),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Terms and Conditions ',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        TextSpan(text: 'and have read the '),
                        TextSpan(
                            text: 'Privacy Policy ',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      )),
    );
  }
}
