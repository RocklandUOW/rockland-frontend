import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rockland/components/alert_dialog.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/components/textfield.dart';
import 'package:rockland/screens/account/register.dart';
import 'package:rockland/screens/home.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:http/http.dart' as http;
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:rockland/utility/rest_operations/post.dart';
import 'package:rockland/utility/strings.dart';
import 'package:rockland/utility/user_provider.dart';

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

  late final formKey;

  @override
  void initState() {
    super.initState();
    loadingDialog = LoadingDialog.construct(context);
    loginResult =
        DismissableAlertDialog(context: context, child: const Text("Result"));
    loginResult.setOkButton(TextButton(
        onPressed: () => loginResult.dismiss(), child: const Text("OK")));
    formKey = GlobalKey<FormState>();
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
        .then((decoded) async {
          loadingDialog.dismiss();

          String responseStr = decoded["detail"].toString().trim();

          if (responseStr == ConnectionStrings.connectionErrResponse) {
            loginResult.setChild(
              const Text(ConnectionStrings.connectionErrString),
            );
            loginResult.show();
          } else if (responseStr == LoginStrings.invalidAccountRes) {
            loginResult.setChild(
              const Text(LoginStrings.invalidAccountStr),
            );
            loginResult.show();
          } else if (responseStr == LoginStrings.invalidPasswordRes) {
            loginResult.setChild(
              const Text(LoginStrings.invalidPasswordStr),
            );
            loginResult.show();
          } else {
            loadingDialog.show();
            TokenValidation? tokenDetails = await PostOperations.validateLogin(
              responseStr,
            );
            loadingDialog.dismiss();
            if (tokenDetails != null) {
              context.read<UserProvider>().setUserId(
                    tokenDetails.detail.userId,
                  );
              // Navigator.of(context).pushAndRemoveUntil(
              //     MaterialPageRoute(
              //       builder: (context) => const HomeScreen(),
              //     ),
              //     (Route<dynamic> route) => false);
              Activity.startActivityAndRemoveHistory(
                context,
                const HomeScreen(),
              );
            } else {
              loginResult.setChild(const Text(
                LoginStrings.validationServiceDown,
              ));
              loginResult.show();
            }
          }
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
    final mediaQuery = MediaQuery.of(context);
    final double parentHeight = mediaQuery.size.height;
    final double parentWidth = mediaQuery.size.width;
    final double safeAreaPadding = mediaQuery.padding.top;

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
          body: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 320,
                      child: Stack(
                        children: [
                          const Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            child: Image(
                              image: AssetImage("lib/images/login_bg.png"),
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: parentWidth,
                              height: parentHeight,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: [0.6, 0.97],
                                  colors: [
                                    Colors.transparent,
                                    CustomColor.mainBrown
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 40,
                            top: 60 + safeAreaPadding,
                            child: CommonButton(
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
                          ),
                          const Positioned(
                            left: 40,
                            bottom: 30,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome!",
                                  style: TextStyle(
                                      color: Colors.white,
                                      height: 1.1,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40),
                                ),
                                Text(
                                  "Happy to meet you again",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Form(
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
                                validator: (value) => _emailValidator(value!)
                                    ? null
                                    : "Please enter a valid email address",
                              ),
                              const SizedBox(
                                height: 25,
                              ),
                              CommonTextField(
                                  controller: passwordController,
                                  hintText: "Password",
                                  style:
                                      GoogleFonts.firaCode(color: Colors.white),
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
                                  bool valid = formKey.currentState!.validate();
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
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: Row(
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
        ));
  }
}
