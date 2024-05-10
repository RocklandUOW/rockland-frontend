import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rockland/components/alert_dialog.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/screens/home.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/common.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:rockland/utility/strings.dart';

class NotificationPage extends StatefulWidget {
  final HomeScreenState? parentState;

  const NotificationPage({super.key, this.parentState});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late DismissableAlertDialog postResult;
  final ImagePicker imagePicker = ImagePicker();
  List<XFile> images = [];
  List<dynamic> posts = [];

  @override
  void initState() {
    super.initState();
    HomeScreen.previousFragment.add(const NotificationPage());
    postResult =
        DismissableAlertDialog(context: context, child: const Text(""));
  }

  void selectImages() async {
    images.clear();
    final List<XFile> selectedImages = await imagePicker.pickMultiImage(
        maxHeight: 1440, maxWidth: 1440, imageQuality: 80);
    if (selectedImages.isNotEmpty) {
      setState(() {
        images.addAll(selectedImages);
      });
    }
  }

  void addPost() async {
    widget.parentState?.loading.show();
    final sendPost = http.MultipartRequest("POST",
        Uri.parse("https://rockland-app-service.onrender.com/add_post/"));
    sendPost.headers["Content-Type"] = "multipart/form-data";
    for (XFile image in images) {
      dynamic imageExtension = image.path.split(".");
      imageExtension = imageExtension[imageExtension.length - 1];
      var imgFile = await http.MultipartFile.fromPath('files', image.path,
          contentType: MediaType("image", imageExtension));
      sendPost.files.add(imgFile);
    }
    sendPost.fields["user_id"] = "663b8a943231c2bdd950335e";
    sendPost.fields["rocktype"] = "andesite";
    sendPost.fields["description"] = "found this andesite on UOW building 41";
    sendPost.fields["latitude"] = "-34.4067433";
    sendPost.fields["longitude"] = "150.8790018";
    try {
      http.StreamedResponse send = await sendPost.send();
      http.Response response = await http.Response.fromStream(send);
      dynamic formattedRes = await jsonDecode(response.body);
      postResult.setChild(Text(formattedRes.toString()));
    } catch (e) {
      postResult.setChild(const Text(ConnectionStrings.unknownErrorString));
    }
    widget.parentState?.loading.dismiss();
    postResult.setOkButton(TextButton(
        onPressed: () => postResult.dismiss(), child: const Text("OK")));
    postResult.show();
  }

  void getPostById() {
    posts.clear();
    widget.parentState?.loading.show();
    http
        .post(
            Uri.parse(
                "https://rockland-app-service.onrender.com/get_post_by_user_id/"),
            headers: <String, String>{"Content-Type": "application/json"},
            body:
                jsonEncode(<String, String>{"id": "663b8a943231c2bdd950335e"}))
        .catchError((e) {
          return http.Response(jsonEncode(["connection error"]), 200);
        })
        .then((response) => jsonDecode(response.body))
        .then((decoded) {
          widget.parentState?.loading.dismiss();

          if ((decoded as List).isEmpty) {
            postResult
                .setChild(const Text("User has not posted anything yet."));
          } else if (decoded[0] == ConnectionStrings.connectionErrResponse) {
            postResult
                .setChild(const Text(ConnectionStrings.connectionErrString));
          } else {
            posts.addAll(decoded);
            postResult.setChild(Text("${posts.map((e) {
              return "[${e["rocktype"]}\n ${e["description"]}\n ${e["picture_url"].map((e) => e)}\n ${e["latitude"]}] ${e["longitude"]}] ${e["hashtags"]}] ${e["comments"]}] ${e["verifications"]}] ${e["liked"]}]\n\n";
            })}"));
          }

          postResult.setOkButton(TextButton(
              onPressed: () => postResult.dismiss(), child: const Text("OK")));
          postResult.show();
        });
  }

  @override
  Widget build(BuildContext context) {
    double parentHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: CustomColor.mainBrown,
      body: SafeArea(
          child: Container(
        decoration: CommonStyles.commonBorder,
        alignment: Alignment.center,
        height: parentHeight,
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const SizedBox(
                height: 200,
              ),
              const Text(
                "Post test",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "rocktype: andesite",
                style: CommonStyles.commonTextStyle,
              ),
              Text(
                "description: found this andesite on UOW building 41",
                style: CommonStyles.commonTextStyle,
              ),
              Text(
                "latitude: -34.4067433",
                style: CommonStyles.commonTextStyle,
              ),
              Text(
                "longitude: 150.8790018",
                style: CommonStyles.commonTextStyle,
              ),
              Text(
                "user_id: 663b8a943231c2bdd950335e",
                style: CommonStyles.commonTextStyle,
              ),
              Text(
                "files: [${images.map((e) => e.path)}]\nlength:${images.length}",
                style: CommonStyles.commonTextStyle,
              ),
              const SizedBox(
                height: 10,
              ),
              CommonButton(
                onPressed: selectImages,
                buttonText:
                    "Select images (will be changed to only use camera later)",
              ),
              const SizedBox(
                height: 10,
              ),
              CommonButton(
                onPressed: addPost,
                buttonText: "Send post",
              ),
              const SizedBox(
                height: 10,
              ),
              CommonButton(
                onPressed: getPostById,
                buttonText: "Get post by user id",
              )
            ],
          ),
        ),
      )),
    );
  }
}
