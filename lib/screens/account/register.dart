import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rockland/components/alert_dialog.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/components/textfield.dart';
import 'package:rockland/screens/account/login.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:http/http.dart' as http;
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/strings.dart';

class RegisterAccount extends StatefulWidget {
  const RegisterAccount({super.key});

  @override
  State<RegisterAccount> createState() => _RegisterAccountState();
}

class _RegisterAccountState extends State<RegisterAccount> {
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordController = TextEditingController();
  final retypePasswordController = TextEditingController();
  bool customBackButtonPressed = false;
  bool loading = false;
  late DismissableAlertDialog loadingDialog;
  late DismissableAlertDialog registerResult;

  @override
  void initState() {
    super.initState();
    loadingDialog = LoadingDialog.construct(context);
    registerResult =
        DismissableAlertDialog(context: context, child: const Text("Result"));
  }

  bool _emailValidator(String value) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$");
    return emailRegex.hasMatch(value);
  }

  bool _passwordValidator(String value) {
    final passwordRegex = RegExp(
        r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()\-_=+;:',<.>/?])[A-Za-z\d!@#$%^&*()\-_=+;:',<.>/?]{8,}$");
    return passwordRegex.hasMatch(value);
  }

  void _activityHandler(BuildContext context) {
    List<Widget> history = Activity.history;
    try {
      if (history[history.length - 2] is LoginAccount) {
        customBackButtonPressed = true;
        Activity.finishActivity(context);
      } else {
        Activity.startActivity(context, const LoginAccount());
      }
    } catch (e) {
      Activity.startActivity(context, const LoginAccount());
    }
  }

  void handleSignUp() {
    loadingDialog.show();
    http
        .post(Uri.parse("https://rockland-app-service.onrender.com/register/"),
            headers: <String, String>{"Content-Type": "application/json"},
            body: jsonEncode(<String, String>{
              "email": emailController.text,
              "first_name": firstNameController.text,
              "last_name": lastNameController.text,
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
            registerResult
                .setChild(const Text(ConnectionStrings.connectionErrString));
          } else if (responseStr == SignUpStrings.accountExistResponse) {
            registerResult
                .setChild(const Text(SignUpStrings.accountExistString));
          } else if (responseStr == SignUpStrings.registrationFailedResponse) {
            registerResult.setChild(const Text(SignUpStrings.failedString));
          } else {
            registerResult.setChild(const Text(SignUpStrings.successString));
          }

          registerResult.setOkButton(TextButton(
              onPressed: () => registerResult.dismiss(),
              child: const Text("OK")));
          registerResult.show();
        });
  }

  @override
  void dispose() {
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    retypePasswordController.dispose();
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
                                  Row(
                                    children: [
                                      Expanded(
                                          child: CommonTextField(
                                              controller: firstNameController,
                                              hintText: "First name",
                                              validator: (value) => value != ""
                                                  ? null
                                                  : "First name cannot be empty",
                                              icon: const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                              ))),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                          child: CommonTextField(
                                        controller: lastNameController,
                                        hintText: "Last name (optional)",
                                        validator: (value) =>
                                            firstNameController.text != ""
                                                ? null
                                                : "",
                                      )),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  CommonTextField(
                                      controller: passwordController,
                                      style: GoogleFonts.firaCode(
                                        color: Colors.white,
                                      ),
                                      hintText: "Password",
                                      validator: (value) => _passwordValidator(
                                              value!)
                                          ? null
                                          : "Password must include an uppercase letter, a digit, a special character, and be a minimum of 8 characters long",
                                      obscureText: true,
                                      icon: const Icon(
                                        Icons.key,
                                        color: Colors.white,
                                      )),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  CommonTextField(
                                      controller: retypePasswordController,
                                      style: GoogleFonts.firaCode(
                                          color: Colors.white),
                                      hintText: "Re-type password",
                                      validator: (value) =>
                                          value == passwordController.text
                                              ? null
                                              : "Passwords do not match",
                                      obscureText: true,
                                      icon: const Icon(
                                        Icons.key,
                                        color: Colors.white,
                                      )),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  CommonButton(
                                    onPressed: () {
                                      bool valid =
                                          formKey.currentState!.validate();
                                      if (valid) {
                                        handleSignUp();
                                      }
                                    },
                                    buttonText: "Sign up",
                                    textColor: Colors.white,
                                    gradient: const LinearGradient(colors: [
                                      CustomColor.buttonOrange,
                                      CustomColor.buttonYellow
                                    ]),
                                  ),
                                ],
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                          RichText(
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(text: 'and have read the '),
                                TextSpan(
                                    text: 'Privacy Policy ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 35,
                          ),
                        ],
                      )
                    ],
                  ),
                )),
                Column(
                  children: [
                    const Divider(
                      thickness: 0.5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 25, right: 25, bottom: 20, top: 10),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: const TextStyle(
                              height: 1.5,
                              color: Colors.white,
                              fontFamily: "Lato"),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Sign in ',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _activityHandler(context),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
        ));
  }
}
