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
  final bool isIcon;
  final Gradient? gradient;
  final Icon? icon;

  const CommonButton(
      {super.key,
      required this.onPressed,
      this.isoutlined = false,
      this.isIcon = false,
      this.isText = false,
      this.size = const Size(250, 40),
      this.foregroundColor = Colors.black26,
      this.backgroundColor = Colors.white,
      this.textColor = Colors.black,
      this.buttonText = "",
      this.gradient,
      this.icon});

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
    } else if (isIcon) {
      return CircleAvatar(
        radius: size!.width/2,
        backgroundColor: backgroundColor,
        child: IconButton(
          onPressed: onPressed,
          style: IconButton.styleFrom(
              elevation: 0,
              foregroundColor: foregroundColor,
              shadowColor: Colors.transparent,
              minimumSize: size),
          icon: icon!,
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
