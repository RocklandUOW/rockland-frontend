import 'package:flutter/material.dart';

class Activity {
  static Future<Widget> _buildPageAsync(
      BuildContext context, Widget activity) async {
    return Future.microtask(() {
      return activity;
    });
  }

  static void startActivity(BuildContext context, Widget activity,
      [int delay = 300]) {
    Future.delayed(Duration(milliseconds: delay), () async {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => activity),
      // );
      var page = await _buildPageAsync(context, activity);
      var route = MaterialPageRoute(builder: (_) => page);
      Navigator.push(context, route);
    });
  }
}
