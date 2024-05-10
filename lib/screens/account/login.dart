import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rockland/components/alert_dialog.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/components/textfield.dart';
import 'package:rockland/screens/account/register.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:http/http.dart' as http;
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/strings.dart';

class LoginAccount extends StatefulWidget {
  const LoginAccount({super.key});

  @override
  State<LoginAccount> createState() => _LoginAccountState();
}

class _LoginAccountState extends State<LoginAccount> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool customBackButtonPressed = false;
  late DismissableAlertDialog loadingDialog;
  late DismissableAlertDialog loginResult;

  @override
  void initState() {
    super.initState();
    loadingDialog = LoadingDialog.construct(context);
    loginResult =
        DismissableAlertDialog(context: context, child: const Text("Result"));
  }

  void _activityHandler(BuildContext context) {
    List<Widget> history = Activity.history;
    try {
      if (history[history.length - 2] is RegisterAccount) {
        customBackButtonPressed = true;
        Activity.finishActivity(context);
      } else {
        Activity.startActivity(context, const RegisterAccount());
      }
    } catch (e) {
      Activity.startActivity(context, const RegisterAccount());
    }
  }

  bool _emailValidator(String value) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$");
    return emailRegex.hasMatch(value);
  }

  void handleSignIn() {
    loadingDialog.show();
    http
        .post(Uri.parse("https://rockland-app-service.onrender.com/login/"),
            headers: <String, String>{"Content-Type": "application/json"},
            body: jsonEncode(<String, String>{
              "email": emailController.text,
              "password": passwordController.text
            }))
        .catchError((e) {
          return http.Response(
              jsonEncode(<String, String>{"detail": "connection error"}), 200);
        })
        .then((response) => jsonDecode(response.body) as Map<String, dynamic>)
        .then((decoded) {
          loadingDialog.dismiss();

          String responseStr = decoded["detail"].toString().trim();

          if (responseStr == ConnectionStrings.connectionErrResponse) {
            loginResult
                .setChild(const Text(ConnectionStrings.connectionErrString));
          } else if (responseStr == LoginStrings.invalidAccountRes) {
            loginResult.setChild(const Text(LoginStrings.invalidAccountStr));
          } else if (responseStr == LoginStrings.invalidPasswordRes) {
            loginResult.setChild(const Text(LoginStrings.invalidPasswordStr));
          } else {
            loginResult.setChild(Text(responseStr));
          }

          loginResult.setOkButton(TextButton(
              onPressed: () => loginResult.dismiss(), child: const Text("OK")));
          loginResult.show();
        });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    customBackButtonPressed = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          Future.delayed(const Duration(milliseconds: 1), () {
            if (!customBackButtonPressed) {
              Activity.finishActivity(context, true);
            }
          });
        },
        child: Scaffold(
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
                                  onPressed: () {
                                    customBackButtonPressed = true;
                                    Activity.finishActivity(context);
                                  },
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
                          Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  CommonTextField(
                                    controller: emailController,
                                    hintText: "Email",
                                    icon: const Icon(
                                      Icons.email,
                                      color: Colors.white,
                                    ),
                                    validator: (value) => _emailValidator(
                                            value!)
                                        ? null
                                        : "Please enter a valid email address",
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  CommonTextField(
                                      controller: passwordController,
                                      hintText: "Password",
                                      style: GoogleFonts.firaCode(
                                          color: Colors.white),
                                      obscureText: true,
                                      icon: const Icon(
                                        Icons.key,
                                        color: Colors.white,
                                      ),
                                      validator: (value) => value != ""
                                          ? null
                                          : "Password cannot be empty"),
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
                                          style: TextStyle(
                                              height: 1.5,
                                              color: Colors.white,
                                              fontFamily: "Lato"),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: 'Reset it',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
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
                                      bool valid =
                                          formKey.currentState!.validate();
                                      if (valid) {
                                        handleSignIn();
                                      }
                                    },
                                    buttonText: "Sign in",
                                    textColor: Colors.white,
                                    gradient: const LinearGradient(colors: [
                                      CustomColor.buttonOrange,
                                      CustomColor.buttonYellow
                                    ]),
                                  )
                                ],
                              )),
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
                            onPressed: () => _activityHandler(context),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 20),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          text: 'By continuing, you agree to the ',
                          style: TextStyle(
                              height: 1.5,
                              color: Colors.white,
                              fontFamily: "Lato"),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Terms and Conditions ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: 'and have read the '),
                            TextSpan(
                                text: 'Privacy Policy ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )),
        ));
  }
}
