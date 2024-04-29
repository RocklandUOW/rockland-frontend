import 'package:flutter/material.dart';
import 'package:rockland/styles/colors.dart';

class ProfileBuilderController {
  late Function() moveHeaderUp;
  late Function() moveHeaderDown;
}

class ProfilePageBuilder extends StatefulWidget {
  final ProfileBuilderController? profileBuilderController;

  const ProfilePageBuilder({super.key, this.profileBuilderController});

  @override
  State<ProfilePageBuilder> createState() => _ProfilePageBuilderState();
}

class _ProfilePageBuilderState extends State<ProfilePageBuilder> {
  bool isProfilePage = true;

  @override
  void initState() {
    super.initState();
    widget.profileBuilderController?.moveHeaderDown = moveHeaderDown;
    widget.profileBuilderController?.moveHeaderUp = moveHeaderUp;
  }

  void moveHeaderUp() {
    setState(() {
      isProfilePage = false;
    });
  }

  void moveHeaderDown() {
    setState(() {
      isProfilePage = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                height: 300,
                transform: Matrix4.identity()
                  ..translate(0.0, isProfilePage ? 0.0 : -50.0),
                color: CustomColor.fifthBrown,
                duration: Duration(milliseconds: 250),
                curve: Curves.ease,
                child: Placeholder(),
              ))
        ],
      )),
    );
  }
}
