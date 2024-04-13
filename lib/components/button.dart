import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final Function()? onPressed;
  final Size? size;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? textColor;
  final String buttonText;
  final bool isoutlined;
  final bool isText;
  final Gradient? gradient;

  const CommonButton(
      {super.key,
      required this.onPressed,
      this.isoutlined = false,
      this.isText = false,
      this.size = const Size(250, 40),
      this.foregroundColor = Colors.black26,
      this.backgroundColor = Colors.white,
      this.textColor = Colors.black,
      this.buttonText = "",
      this.gradient});

  @override
  Widget build(BuildContext context) {
    if (isoutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
            elevation: 0,
            foregroundColor: foregroundColor,
            side: BorderSide(color: backgroundColor!),
            shadowColor: Colors.transparent,
            minimumSize: size),
        child: Text(
          buttonText,
          style: TextStyle(color: textColor),
        ),
      );
    } else if (isText) {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
            elevation: 0,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            minimumSize: size),
        child: Text(
          buttonText,
          style: TextStyle(color: textColor),
        ),
      );
    } else {
      return Container(
        width: size!.width,
        height: size!.height,
        decoration: gradient == null
            ? null
            : BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(size!.height)),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor:
                  gradient == null ? foregroundColor : Colors.white,
              backgroundColor:
                  gradient == null ? backgroundColor : Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: size),
          child: Text(
            buttonText,
            style: TextStyle(color: textColor),
          ),
        ),
      );
    }
  }
}
