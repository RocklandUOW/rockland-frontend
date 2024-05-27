import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:provider/provider.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:rockland/utility/user_provider.dart';

class TriviaGame extends StatefulWidget {
  final bool isFirstOpen;

  const TriviaGame({super.key, this.isFirstOpen = true});

  @override
  State<TriviaGame> createState() => _TriviaGameState();
}

class _TriviaGameState extends State<TriviaGame> {
  UnityWidgetController? gameController;
  User currentUser = User();
  bool isUserSet = false;
  Timer? initialisingTimer;

  @override
  void initState() {
    currentUser = context.read<UserProvider>().user;
    super.initState();
  }

  @override
  void dispose() {
    gameController?.dispose();
    initialisingTimer?.cancel();
    super.dispose();
  }

  // Callback that connects the created controller to the unity controller
  void onUnityCreated(UnityWidgetController controller) async {
    gameController = controller;
    if (widget.isFirstOpen) {
      initialisingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        Activity.finishActivityWithResult(context, {"gameLoaded": false});
      });
    }
  }

  void onUnityMessage(message) {
    print('Received message from unity: ${message.toString()}');
    if (!widget.isFirstOpen && !isUserSet) {
      gameController?.postMessage(
        "API_Manager",
        "SetCurrentUser",
        currentUser.id,
      );
      isUserSet = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double safeAreaPadding = mediaQuery.padding.top;

    return Consumer<UserProvider>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: CustomColor.mainBrown,
        body: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: Column(
                children: [
                  Expanded(child: Container()),
                  Text(
                    "Initialising game...",
                    style: CommonStyles.commonTextStyle,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: CustomColor.extremelyLightBrown,
                      strokeWidth: 3,
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ),
            IgnorePointer(
              ignoring: widget.isFirstOpen,
              child: Opacity(
                opacity: widget.isFirstOpen ? 0 : 1,
                child: UnityWidget(
                  onUnityCreated: onUnityCreated,
                  onUnityMessage: onUnityMessage,
                  useAndroidViewSurface: false,
                  unloadOnDispose: true,
                  runImmediately: true,
                  fullscreen: true,
                ),
              ),
            ),
            Positioned(
              left: 40,
              top: 40 + safeAreaPadding,
              child: CommonButton(
                onPressed: () {
                  Activity.finishActivity(context);
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
          ],
        ),
      ),
    );
  }
}
