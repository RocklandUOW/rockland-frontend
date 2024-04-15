import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/components/textfield.dart';
import 'package:rockland/screens/account/login.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';

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
    List<Widget> _history = Activity.history;
    try {
      if (_history[_history.length - 2] is LoginAccount) {
        customBackButtonPressed = true;
        Activity.finishActivity(context);
      } else {
        Activity.startActivity(context, const LoginAccount());
      }
    } catch (e) {
      Activity.startActivity(context, const LoginAccount());
    }
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
    final _formKey = GlobalKey<FormState>();

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
                              key: _formKey,
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
                                      _formKey.currentState!.validate();
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
                          style: const TextStyle(height: 1.5),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Sign in ',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _activityHandler(context),
                                style: const TextStyle(
                                    color: Colors.white,
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
