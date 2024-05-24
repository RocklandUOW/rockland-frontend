import 'package:flutter/material.dart';
import 'package:rockland/components/alert_dialog.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/model.dart';
import 'package:rockland/utility/strings.dart';

extension StringExtension on String {
  String capitalize() {
    if (trim().isEmpty) {
      return "";
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String removeExtraSpaces() {
    return replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String capitalizeWord() {
    return split(' ').map((word) {
      if (word.isEmpty) return '';
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }
}

class ErrorBuilder {
  static Error build(int code) {
    String description;
    if (code == 999) {
      description = ConnectionStrings.connectionErrString;
    } else if (code == 504) {
      description =
          "Server is currently under maintenance, please try again later. If the server has been down for a long time, please inform us.";
    } else {
      description =
          "An uknown error has occured. Please inform us about this immediately.";
    }
    return Error(errorCode: code, description: description);
  }
}

class Common {
  static const Duration duration100 = Duration(milliseconds: 100);
  static const Duration duration150 = Duration(milliseconds: 150);
  static const Duration duration250 = Duration(milliseconds: 250);
  static const Duration duration300 = Duration(milliseconds: 300);
}

class CommonStyles {
  static BoxDecoration commonBorder =
      BoxDecoration(border: Border.all(color: Colors.white, width: 2));
  static TextStyle commonTextStyle = const TextStyle(color: Colors.white);
  static TextStyle mainBrownText =
      const TextStyle(color: CustomColor.mainBrown);
}

class LoadingDialog {
  static DismissableAlertDialog construct(BuildContext context) {
    return DismissableAlertDialog(
      context: context,
      barrierDismissable: false,
      child: const Wrap(
        alignment: WrapAlignment.center,
        children: [
          Column(
            children: [
              Text(
                "Loading...",
              ),
              Text(
                "Please don't press anything",
              ),
              SizedBox(
                height: 15,
              ),
              SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(),
              )
            ],
          )
        ],
      ),
    );
  }
}

