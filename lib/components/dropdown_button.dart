import 'package:flutter/material.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:rockland/utility/rest_operations/get.dart';

class ChooseRockDropdownController {
  late String dropDownValue;
  late String dropDownHintText;
}

class ChooseRockDropdown extends StatefulWidget {
  final ChooseRockDropdownController controller;
  final double borderRadius;
  final String hintText;
  final Color backgroundColor;

  const ChooseRockDropdown(
      {super.key,
      required this.controller,
      this.borderRadius = 20,
      this.hintText = "Select a rock that matches",
      this.backgroundColor = CustomColor.fifthBrown});

  @override
  State<ChooseRockDropdown> createState() => ChooseRockDropdownState();
}

class ChooseRockDropdownState extends State<ChooseRockDropdown> {
  String dropDownValue = "null";
  List<Rock> rocks = [];

  @override
  void initState() {
    super.initState();
    widget.controller.dropDownValue = dropDownValue;
    getRocks();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> getRocks() async {
    final rockList = await GetOperations.getRockInfo(context);
    setState(() {
      for (dynamic rock in rockList) {
        rocks.add(Rock.fromJson(rock));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius))),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: DropdownButton<String>(
          style: const TextStyle(
              fontSize: 14, fontFamily: "Lato", color: Colors.white),
          dropdownColor: CustomColor.fifthBrown,
          iconEnabledColor: Colors.white,
          isExpanded: true,
          value: widget.controller.dropDownValue,
          onChanged: (value) {
            print(value);
            setState(() {
              widget.controller.dropDownValue = value!;
            });
          },
          underline: Container(
            height: 0,
          ),
          items: <DropdownMenuItem<String>>[
            DropdownMenuItem(
              value: "null",
              child: Text(
                widget.controller.dropDownHintText,
              ),
            ),
            ...rocks.map(
              (rockData) => DropdownMenuItem(
                value: rockData.name,
                child: Text(
                  rockData.rock["name"],
                  style: CommonStyles.commonTextStyle,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
