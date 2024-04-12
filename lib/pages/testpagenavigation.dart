import 'package:flutter/material.dart';

class NavigationTest extends StatelessWidget {
  const NavigationTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Text(
              "Navigation test. Press the native back button to go back to the previous screen."),
        ),
      ),
    );
  }
}
