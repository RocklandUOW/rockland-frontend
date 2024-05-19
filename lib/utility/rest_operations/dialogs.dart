import 'package:flutter/material.dart';
import 'package:rockland/components/alert_dialog.dart';

class ErrorDialog extends DismissableAlertDialog {
  DismissableAlertDialog? error;

  ErrorDialog({
    this.error,
    super.child = const Text("data"),
    required super.context,
  });

  void construct(String description) {
    error = DismissableAlertDialog(context: context, child: Text(description));
    error!.setOkButton(TextButton(onPressed: () {}, child: const Text("OK")));
  }
}
