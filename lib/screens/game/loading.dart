import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:provider/provider.dart';
import 'package:rockland/screens/game/trivia.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:rockland/utility/user_provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class GameLoadingScreen extends StatefulWidget {
  final bool isFirstOpen;

  const GameLoadingScreen({super.key, this.isFirstOpen = true});

  @override
  State<GameLoadingScreen> createState() => _GameLoadingScreenState();
}

class _GameLoadingScreenState extends State<GameLoadingScreen> {
  UnityWidgetController? gameController;
  bool isFirstOpen = true;
  User currentUser = User();

  @override
  void initState() {
    super.initState();
    currentUser = context.read<UserProvider>().user;
  }

  @override
  void dispose() {
    gameController?.dispose();
    super.dispose();
  }

  // Callback that connects the created controller to the unity controller
  void onUnityCreated(UnityWidgetController controller) async {
    gameController = controller;
    if (widget.isFirstOpen) {
      Map? results = await Activity.startActivityForResult(
        context,
        const TriviaGame(),
      );
      if (results != null && results.containsKey("gameLoaded")) {
        if (!results["gameLoaded"]) {
          Activity.startActivity(
            context,
            const TriviaGame(isFirstOpen: false),
          );
        }
      }
    } else {
      Activity.startActivity(context, const TriviaGame(isFirstOpen: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: CustomColor.mainBrown,
        body: Stack(
          children: [
            IgnorePointer(
              child: Opacity(
                opacity: 0,
                child: UnityWidget(
                  onUnityCreated: onUnityCreated,
                  useAndroidViewSurface: false,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: VisibilityDetector(
                key: const Key("visibilitydetectortrivia"),
                onVisibilityChanged: (info) {
                  if (info.visibleFraction == 1.0) {
                    Activity.finishActivity(context);
                  }
                },
                child: Column(
                  children: [
                    Expanded(child: Container()),
                    Text(
                      "Opening game...",
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
            ),
          ],
        ),
      ),
    );
  }
}
