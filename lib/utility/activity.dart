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

  static void startActivity(BuildContext context, Widget activity,
      [int delay = 300]) {
    Future.delayed(Duration(milliseconds: delay), () async {
      history.add(activity);
      var page = await _buildPageAsync(context, activity);
      var route = MaterialPageRoute(builder: (_) => page);
      Navigator.push(context, route);
    });
  }
}
