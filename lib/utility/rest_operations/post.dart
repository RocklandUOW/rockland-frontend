import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockland/utility/rest_operations/dialogs.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:rockland/utility/model.dart';
import 'package:rockland/utility/strings.dart';

class PostOperations {
  static bool isRockLoading = true;
  static bool isLoading = true;
  static bool isIdentified = true;
  static bool rockHasError = false;
  static bool hasError = false;
  static late Error internalRockErr;
  static late Error internalErr;
  static late Error error;
  static late ErrorDialog errorDialog;

  static Future<Rock?> identifyRock(
    BuildContext context,
    String imagePath,
  ) async {
    Rock? rock;
    try {
      dynamic imageExtension = imagePath.split(".");
      imageExtension = imageExtension[imageExtension.length - 1];
      final predict = http.MultipartRequest(
        "POST",
        Uri.parse("https://rockland-ai.ddns.net/predict"),
      );
      predict.headers["Content-Type"] = "multipart/form-data";
      var imgFile = await http.MultipartFile.fromPath(
        "file",
        imagePath,
        contentType: MediaType("image", imageExtension),
      );
      predict.files.add(imgFile);

      // send
      dynamic formattedResponse;
      try {
        http.StreamedResponse post = await predict.send();
        http.Response response = await http.Response.fromStream(post);
        if (response.statusCode == 200) {
          formattedResponse = await jsonDecode(response.body);
        } else if (response.statusCode == 504) {
          // gateway time out -> docker is not up
          throw internalErr = Error(
            errorCode: response.statusCode,
            description:
                "Gateway time out on rock prediction service. There's a possibility that the Docker container is not yet running.",
          );
        } else {
          throw internalErr = Error(
            errorCode: response.statusCode,
            description:
                "Error happened on the rock prediction service with the error code as stated.",
          );
        }
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      String identifiedRock = formattedResponse["class_name"];
      print(identifiedRock);
      // String identifiedRock = "opal";

      if (identifiedRock != RockIdentificationStrings.notIdentifiedResponse) {
        final req = await http.post(
          Uri.parse(
            "https://rockland-app-service.onrender.com/get_rock_data_by_name/?name=$identifiedRock",
          ),
          headers: <String, String>{
            'Content-Type': 'application/json',
          },
        ).catchError((e) {
          return http.Response(
              jsonEncode(
                <String, String>{"detail": e.toString()},
              ),
              999);
        });

        if (req.statusCode == 200) {
          // setState(() {
          // });
          rock = Rock.fromJson(jsonDecode(req.body));
          isLoading = false;
          isIdentified = true;
        } else if (req.statusCode == 999) {
          throw internalErr = Error(
              errorCode: req.statusCode,
              description: ConnectionStrings.connectionErrString);
        } else {
          throw internalErr = Error(
              errorCode: req.statusCode,
              description: ConnectionStrings.unknownErrorString);
        }
      } else {
        // setState(() {
        // });
        isLoading = false;
        isIdentified = false;
      }
    } catch (e) {
      // setState(() {
      // });
      errorDialog = ErrorDialog(context: context);

      if (e is Error) {
        errorDialog.construct(e.description);
      } else {
        errorDialog.construct(e.toString());
      }

      internalErr = Error(errorCode: 17, description: e.toString());
      isLoading = false;
      isIdentified = false;
      hasError = true;

      errorDialog.show();
    }
    return rock;
  }

  static Future<TokenValidation?> validateLogin(String token) async {
    TokenValidation? tokenDetails;
    isLoading = true;
    const url = "https://rockland-app-service.onrender.com/validate_token/";
    try {
      http.Response response;
      try {
        response = await http.post(
          Uri.parse(url),
          headers: <String, String>{"Content-Type": "application/json"},
          body: jsonEncode(<String, String>{"token": token}),
        );
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        final dynamic formatted = jsonDecode(response.body);
        isLoading = false;
        print(formatted);
        tokenDetails = TokenValidation.fromJson(formatted);
        // setState(() {
        // });
      } else {
        throw internalErr = Error(
          errorCode: response.statusCode,
          description:
              "A server error has occured on the login token validation service. Status code is as stated.",
        );
      }
    } catch (e) {
      // setState(() {
      // });
      isLoading = false;
      hasError = false;
      print(e.toString());
      // to display to the user.
      // error = ErrorBuilder.build(internalErr.errorCode);
    }
    return tokenDetails;
  }

  static Future<User?> getUser(String userId) async {
    User? user;
    const url = "https://rockland-app-service.onrender.com/get_account_by_id/";
    isLoading = true;
    try {
      http.Response response;
      try {
        response = await http.post(Uri.parse(url),
            headers: <String, String>{"Content-Type": "application/json"},
            body: jsonEncode(<String, String>{
              "id": userId,
            }));
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> userDetails = jsonDecode(response.body);
        // setState(() {
        // });
        user = User.fromJson(userDetails);
        isLoading = false;
      } else {
        throw internalErr = Error(
          errorCode: response.statusCode,
          description:
              "A server error has occured on the discover service. Status code is as stated.",
        );
      }
    } catch (e) {
      // setState(() {
      // });
      isLoading = false;
      hasError = false;
      if (e is Error) {
        print((e as Error).errorCode);
        print((e as Error).description);
      } else {
        print(e.toString());
      }
      // to display to the user.
      // error = ErrorBuilder.build(internalErr.errorCode);
    }
    return user;
  }

  static Future<List<Post>> getPostsByRadiusKm(
      double latitude, double longitude) async {
    List<Post> posts = [];
    const url =
        "https://rockland-app-service.onrender.com/get_posts_by_radius/";
    isLoading = true;
    try {
      http.Response response;
      try {
        response = await http.post(Uri.parse(url),
            headers: <String, String>{"Content-Type": "application/json"},
            body: jsonEncode(
              <String, dynamic>{
                "rocktypes": [],
                "latitude": latitude,
                "longitude": longitude,
                "radius": 3
              },
            ));
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        final List<dynamic> postsByRadius = jsonDecode(response.body);
        print(postsByRadius);
        // setState(() {
        // });
        for (dynamic post in postsByRadius) {
          posts.add(Post.fromJson(post));
        }
        isLoading = false;
      } else {
        throw internalErr = Error(
          errorCode: response.statusCode,
          description:
              "A server error has occured on the discover service. Status code is as stated.",
        );
      }
    } catch (e) {
      // setState(() {
      // });
      isLoading = false;
      hasError = false;
      if (e is Error) {
        print((e as Error).errorCode);
        print((e as Error).description);
      } else {
        print(e.toString());
      }
      // to display to the user.
      // error = ErrorBuilder.build(internalErr.errorCode);
    }
    return posts;
  }
}
