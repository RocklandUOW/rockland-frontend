import 'package:flutter/material.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: SafeArea(
          child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 25),
          child: ListView(
            children: List<Widget>.generate(
              50,
              (int index) => Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 25),
                  child: Text(
                    "list item $index",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ),
      )),
    );
  }
}
