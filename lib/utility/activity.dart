import 'package:flutter/material.dart';

class Activity {
  static List<Widget> history = [];

  static Future<Widget> _buildPageAsync(
      BuildContext context, Widget activity) async {
    return Future.microtask(() {
      return activity;
    });
  }

  static void finishActivity(BuildContext context,
      [bool systemBackPressed = false]) {
    history.removeLast();
    if (!systemBackPressed) {
      Navigator.of(context).pop();
    }
  }

  static void finishActivityWithResult(BuildContext context, dynamic result) {
    history.removeLast();
    Navigator.of(context).pop(result);
  }

  static void startActivity(BuildContext context, Widget activity,
      [int delay = 0]) {
    Future.delayed(Duration(milliseconds: delay), () async {
      history.add(activity);
      var page = await _buildPageAsync(context, activity);
      var route = MaterialPageRoute(builder: (_) => page);
      Navigator.push(context, route);
    });
  }

  static Future<dynamic> startActivityForResult(
      BuildContext context, Widget activity) {
    history.add(activity);
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => activity,
    ));
  }

  static void startActivityAndRemoveHistory(
    BuildContext context,
    Widget activity,
  ) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => activity),
        (Route<dynamic> route) => false);
  }
}
