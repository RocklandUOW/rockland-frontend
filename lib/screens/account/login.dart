import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/components/textfield.dart';
import 'package:rockland/screens/account/register.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';

class LoginAccount extends StatefulWidget {
  const LoginAccount({super.key});

  @override
  State<LoginAccount> createState() => _LoginAccountState();
}

class _LoginAccountState extends State<LoginAccount> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool customBackButtonPressed = false;

  void _activityHandler(BuildContext context) {
    List<Widget> _history = Activity.history;
    try {
      if (_history[_history.length - 2] is RegisterAccount) {
        customBackButtonPressed = true;
        Activity.finishActivity(context);
      } else {
        Activity.startActivity(context, const RegisterAccount());
      }
    } catch (e) {
      Activity.startActivity(context, const RegisterAccount());
    }
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
                                      )),
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
                                      _formKey.currentState!.validate();
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
        ));
  }
}
