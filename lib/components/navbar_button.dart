import 'package:flutter/material.dart';
import 'package:rockland/components/button.dart';

class CustomNavbarButton extends StatefulWidget {
  final Icon icon;
  final int buttonIndex;
  final Function()? onPressed;
  final PageController pageController;
  final String subtitle;

  const CustomNavbarButton(
      {super.key,
      required this.icon,
      required this.onPressed,
      required this.buttonIndex,
      required this.pageController,
      required this.subtitle});

  @override
  State<CustomNavbarButton> createState() => CustomNavbarButtonState();
}

class CustomNavbarButtonState extends State<CustomNavbarButton> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
              child: CommonButton(
            onPressed: widget.onPressed,
            isIcon: true,
            icon: widget.icon,
            size: const Size(70, 60),
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
          )),
          Positioned(
              bottom: 7,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeInOut,
                transform: Transform.translate(
                        offset: Offset(
                            0,
                            widget.buttonIndex == widget.pageController.page
                                ? 0
                                : 3))
                    .transform,
                child: AnimatedOpacity(
                  opacity:
                      widget.buttonIndex == widget.pageController.page ? 1 : 0,
                  duration: const Duration(milliseconds: 100),
                  child: Text(
                    widget.subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
