import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/common.dart';

class SettingsListCard extends StatelessWidget {
  final Function() onPress;
  final String title;

  const SettingsListCard(
      {super.key, required this.title, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: CommonStyles.commonTextStyle,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
