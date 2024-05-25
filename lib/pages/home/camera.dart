import 'dart:convert';
import 'dart:io';
import 'dart:core';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rockland/components/alert_dialog.dart';
import 'package:rockland/components/camera_page_builder.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/components/rock_info.dart';
import 'package:rockland/screens/home.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/model.dart';
import 'package:rockland/utility/strings.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CameraPageController {
  late Function()? takePhoto;
}

class CameraPage extends StatefulWidget {
  final CameraPageController? controller;
  final HomeScreenState? parentState;

  const CameraPage({super.key, this.controller, this.parentState});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  PopUpContainerController controller = PopUpContainerController();
  final ImagePicker imagePicker = ImagePicker();
  XFile? firstPhoto;
  late PermissionStatus mediaPermissionStatus;
  late DismissableAlertDialog permissionDeniedDialog;
  Rock? rock;
  Rock placeholder = Rock(id: "iyah", name: "andesite", rock: {
    "identifier": "andesite",
    "name": "Andesite",
    "images": [
      "https://upload.wikimedia.org/wikipedia/commons/thumb/0/06/Andesite_%2815115877887%29.png/1200px-Andesite_%2815115877887%29.png",
      "https://as2.ftcdn.net/v2/jpg/03/10/45/19/1000_F_310451938_FBo1camycEWIPMf6YP5EWzxEyyZyxBR2.jpg",
      "https://www.mindat.org/imagecache/51/32/08749620015101690587119.jpg",
      "https://i0.wp.com/geologyscience.com/wp-content/uploads/2023/09/Andesite-jpg.webp?resize=900%2C599&ssl=1"
    ],
    "description": ["123", "oh my god it's a rock"],
    "density": "jkdsjksdjksjk",
    "wikipedia": "https://wikipedia.org",
  });
  Error? error;
  Error? internalErr;

  bool isFirstOpen = true; //TODO: set to true
  bool isIdentified = false; //TODO: set to false
  bool hasError = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    HomeScreen.previousFragment.add(const CameraPage());
    widget.controller?.takePhoto = takePhoto;
    permissionDeniedDialog = DismissableAlertDialog(
      context: context,
      child: const Text(PermissionStrings.mediaPermissionDenied),
      cancelButton: TextButton(
        onPressed: () async {
          await openAppSettings();
        },
        child: const Text("Go to settings"),
      ),
      okButton: TextButton(
        onPressed: () {
          permissionDeniedDialog.dismiss();
        },
        child: const Text("OK"),
      ),
    );
    checkPermission().then((_) {
      // call the method on first page open since the controller
      // on parent hasn't been initialised yet. if user taps
      // on the navbar again then the method will be called from
      // parent.
      if (isFirstOpen) {
        takePhoto();
      }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    // set controller to null to prevent already active error
    // (this page) and disposed setstate error (in parent)
    widget.controller?.takePhoto = null;
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<PermissionStatus> requestPermission() async {
    PermissionStatus result;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      result = await Permission.photos.request();
    } else {
      result = await Permission.storage.request();
    }
    return result;
  }

  Future<void> checkPermission() async {
    mediaPermissionStatus = await requestPermission();
    if (mediaPermissionStatus.isDenied ||
        mediaPermissionStatus.isPermanentlyDenied) {
      await permissionDeniedDialog.show();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      mediaPermissionStatus = await Permission.photos.status;
      if (mediaPermissionStatus.isGranted && permissionDeniedDialog.isShowing) {
        try {
          permissionDeniedDialog.dismiss();
        } catch (_) {}
      }
    }
  }

  void takePhoto() async {
    // The image can be compressed after it's picked but it's way
    // more tedious to do so rather than directly resizing it
    // through image picker
    XFile? taken = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1440,
        maxHeight: 1440,
        imageQuality: 80);

    if (taken != null) {
      setState(() {
        widget.parentState?.postImages = [File(taken.path)];
        firstPhoto = taken;
        isFirstOpen = false;
        isLoading = true;
      });

      // identify the rock
      try {
        dynamic imageExtension = taken.path.split(".");
        imageExtension = imageExtension[imageExtension.length - 1];
        final predict = http.MultipartRequest(
          "POST",
          Uri.parse("https://rockland-ai.ddns.net/predict"),
        );
        predict.headers["Content-Type"] = "multipart/form-data";
        var imgFile = await http.MultipartFile.fromPath(
          "file",
          taken.path,
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
            setState(() {
              rock = Rock.fromJson(jsonDecode(req.body));
              // TODO: set first name and last name to be the credit
              (rock!.rock["images"] as List<dynamic>).add({
                "credit": "insert first name last name here",
                "link": taken.path
              });
              isLoading = false;
              isIdentified = true;
            });
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
          setState(() {
            isLoading = false;
            isIdentified = false;
          });
        }
      } catch (e) {
        setState(() {
          internalErr = Error(errorCode: 17, description: e.toString());
          isLoading = false;
          isIdentified = false;
          hasError = true;
        });
      }

      if (mediaPermissionStatus.isGranted) {
        // initialisation
        Uint8List decodedImg = await taken.readAsBytes();
        Directory? storageDir, picturesDir;
        File file;

        // get directories, make the external directory if doesn't exist
        storageDir = await getExternalStorageDirectory();

        // android only fuck you ios
        picturesDir = Directory("/storage/emulated/0/Pictures/Rockland");
        await Directory(picturesDir.path).create(recursive: true);

        // write the file to app's internal file then copy to external
        // storage. directly writing to external storage causes the
        // "image scanned to null" error
        file = File(path.join(storageDir!.path, path.basename(taken.path)));
        await file.writeAsBytes(decodedImg);
        await file.copy(path.join(picturesDir.path, file.path.split("/").last));
        await file.delete(); // minimise app's storage space
      }
    } else {
      setState(() {
        isFirstOpen = false;
        isLoading = false;
        isIdentified = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.mainBrown,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: isFirstOpen
              ? CameraPageBuilder.whenFirstOpened()
              : isLoading
                  ? CameraPageBuilder.whenLoading()
                  : hasError
                      ? [
                          Text(internalErr!.errorCode.toString()),
                          Text(internalErr!.description),
                        ]
                      : isIdentified
                          ? [RockInformation(identifiedRock: rock!)]
                          : CameraPageBuilder.whenNotIdentified(takePhoto),
        ),
      ),
    );
  }
}
