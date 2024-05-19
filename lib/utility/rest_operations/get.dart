import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rockland/utility/model.dart';
import 'package:rockland/utility/rest_operations/dialogs.dart';
import 'package:rockland/utility/strings.dart';

class GetOperations {
  static bool isRockLoading = true;
  static bool rockHasError = false;
  static late Error internalRockErr;
  static late Error internalErr;
  static late Error error;
  static late ErrorDialog errorDialog;

  static Future<List<dynamic>> getRockInfo(BuildContext context) async {
    List<dynamic> getResult = [];
    isRockLoading = true;
    // setState(() {
    // });
    try {
      final req = await http
          .get(Uri.parse(
        "https://rockland-app-service.onrender.com/get_all_rocks/",
      ))
          .catchError((e) {
        return http.Response(
            jsonEncode(
              <String, String>{"detail": e.toString()},
            ),
            999);
      });

      if (req.statusCode == 200) {
        getResult = jsonDecode(req.body);

        // setState(() {
        //   for (dynamic rock in getResult) {
        //     rocks.add(Rock.fromJson(rock));
        //   }
        //   isRockLoading = false;
        // });
      } else if (req.statusCode == 999) {
        throw internalErr = Error(
            errorCode: req.statusCode,
            description: ConnectionStrings.connectionErrString);
      } else {
        throw internalErr = Error(
            errorCode: req.statusCode,
            description: ConnectionStrings.unknownErrorString);
      }
    } catch (e) {
      isRockLoading = false;
      rockHasError = false;
      errorDialog = ErrorDialog(context: context);
      if (e is Error) {
        print(e.errorCode);
        print(e.description);
        errorDialog.construct(e.description);
      } else {
        print(e.toString());
        errorDialog.construct(e.toString());
      }
      errorDialog.show();
      // to display to the user.
      // error = ErrorBuilder.build(internalErr.errorCode);
      // setState(() {
      // });
    }
    return getResult;
  }
}
