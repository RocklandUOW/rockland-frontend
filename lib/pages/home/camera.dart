import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/tests/resizeable_drag.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  ResizeDragController controller = ResizeDragController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResizeDrag(
        controller: controller,
        middleHeight: MediaQuery.of(context).size.height / 2 + 100,
        maxHeight: MediaQuery.of(context).size.height,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: CommonButton(
                onPressed: () {
                  controller.showPopup();
                },
                buttonText: "Show popup lol",
                foregroundColor: Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }
}
