import 'package:flutter/material.dart';
import 'package:rockland/styles/colors.dart';

class DismissableAlertDialog {
  Widget child;
  Widget? okButton;
  Widget? cancelButton;
  bool isShowing;
  final BuildContext context;
  final String? title;
  final double? elevation;
  final bool barrierDismissable;

  DismissableAlertDialog(
      {required this.context,
      required this.child,
      this.title,
      this.okButton,
      this.cancelButton,
      this.elevation = 24,
      this.isShowing = false,
      this.barrierDismissable = true});

  Future<void> show() {
    isShowing = true;
    List<Widget> actions = [];
    cancelButton != null ? actions.add(cancelButton!) : null;
    okButton != null ? actions.add(okButton!) : null;

    AlertDialog alert = AlertDialog(
      title: title != null
          ? Text(title!)
          : const Text(
              "",
              style: TextStyle(fontSize: 5),
            ),
      backgroundColor: CustomColor.extremelyLightBrown,
      elevation: elevation,
      actions: actions,
      content: child,
    );

    return showDialog(
      context: context,
      barrierDismissible: barrierDismissable,
      builder: (context) {
        return alert;
      },
    );
  }

  void dismiss() {
    isShowing = false;
    Navigator.pop(context);
  }

  void setChild(Widget child) {
    this.child = child;
  }

  void setOkButton(Widget okButton) {
    this.okButton = okButton;
  }

  void setCancelButton(Widget? cancelButton) {
    this.cancelButton = cancelButton;
  }
}
