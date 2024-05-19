import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rockland/components/alert_dialog.dart';
import 'package:rockland/components/button.dart';
import 'package:rockland/components/dropdown_button.dart';
import 'package:rockland/components/new_post/add_new_photo_card.dart';
import 'package:rockland/components/new_post/get_location_card.dart';
import 'package:rockland/components/new_post/photo_preview_card.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:rockland/utility/rest_operations/post.dart';
import 'package:rockland/utility/strings.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:rockland/utility/user_provider.dart';

class NewPostScreen extends StatefulWidget {
  final List<File>? initialPhotos;
  final String? rockType;

  const NewPostScreen({super.key, this.initialPhotos, this.rockType});

  @override
  State<NewPostScreen> createState() => NewPostScreenState();
}

class NewPostScreenState extends State<NewPostScreen>
    with WidgetsBindingObserver {
  TextEditingController controller = TextEditingController();
  ChooseRockDropdownController dropController = ChooseRockDropdownController();

  String dropDownHintText = "Select rock type";
  String rockType = "";
  bool isFirstOpen = true; //TODO: set to true

  List<File> photosList = [];
  late final GlobalKey<FormState> formKey;

  late PermissionStatus mediaPermissionStatus;
  late DismissableAlertDialog permissionDeniedDialog;
  final ImagePicker imagePicker = ImagePicker();
  bool isLoading = false;
  late DismissableAlertDialog loading;
  late DismissableAlertDialog postResult;

  User user = User();

  @override
  void initState() {
    super.initState();
    if (widget.initialPhotos != null) {
      photosList.addAll(widget.initialPhotos!);
    }

    user = context.read<UserProvider>().user;

    formKey = GlobalKey<FormState>();
    if (widget.rockType != null) {
      rockType = widget.rockType!;
    }

    dropController.dropDownHintText = "Select a rock type";

    loading = LoadingDialog.construct(context);

    postResult =
        DismissableAlertDialog(context: context, child: const Text(""));

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
    await checkPermission();

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
        photosList.add(File(taken.path));
        isLoading = true;
      });

      // identify the rock
      if (rockType == "" && isFirstOpen) {
        await identifyRock(photosList[0]);
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
        isLoading = false;
        isFirstOpen = false;
      });
    }
  }

  Future<void> identifyRock(File image) async {
    setState(() {
      dropController.dropDownHintText = "Identifying...";
    });
    final identifiedRock =
        await PostOperations.identifyRock(context, image.path);
    setState(() {
      if (identifiedRock != null) {
        rockType = identifiedRock.name;
        dropController.dropDownValue = identifiedRock.name;
        dropController.dropDownHintText = identifiedRock.rock["name"];
      } else {
        dropController.dropDownHintText = "Select a rock type";
        dropController.dropDownValue = "null";
      }
    });
  }

  void addPost() async {
    loading.show();
    final sendPost = http.MultipartRequest("POST",
        Uri.parse("https://rockland-app-service.onrender.com/add_post/"));
    sendPost.headers["Content-Type"] = "multipart/form-data";
    for (File image in photosList) {
      dynamic imageExtension = image.path.split(".");
      imageExtension = imageExtension[imageExtension.length - 1];
      var imgFile = await http.MultipartFile.fromPath('files', image.path,
          contentType: MediaType("image", imageExtension));
      sendPost.files.add(imgFile);
    }
    sendPost.fields["user_id"] = user.id;
    sendPost.fields["rocktype"] = dropController.dropDownValue;
    sendPost.fields["description"] = controller.text;
    sendPost.fields["latitude"] = "-34.4067433";
    sendPost.fields["longitude"] = "150.8790018";
    sendPost.files.add(http.MultipartFile.fromString(
        "hashtags", dropController.dropDownValue));
    try {
      http.StreamedResponse send = await sendPost.send();
      http.Response response = await http.Response.fromStream(send);
      dynamic formattedRes = await jsonDecode(response.body);
      postResult
          .setChild(Text((formattedRes["detail"] as String).capitalize()));
    } catch (e) {
      postResult.setChild(const Text(ConnectionStrings.unknownErrorString));
    }
    loading.dismiss();
    postResult.setOkButton(TextButton(
        onPressed: () => postResult.dismiss(), child: const Text("OK")));
    await postResult.show();
    Activity.finishActivity(context);
    context.read<UserProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double safeAreaPadding = mediaQuery.padding.top;
    final double parentWidth = mediaQuery.size.width;
    final double thumbnailWidth = parentWidth / 2;
    // final double parentHeight = mediaQuery.size.height;
    // final double middleHeight = parentHeight / 2 + 100;
    // final double maxHeight = parentHeight - safeAreaPadding;

    return Scaffold(
      backgroundColor: CustomColor.mainBrown,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: CustomColor.mainBrown,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 15,
                right: 0,
                top: 20 + safeAreaPadding,
                bottom: 5,
              ),
              child: Stack(
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () => Activity.finishActivity(context),
                          style: IconButton.styleFrom(
                              foregroundColor: Colors.white),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      const Flexible(
                        child: AnimatedSize(
                          duration: Common.duration300,
                          curve: Curves.ease,
                          child: Text(
                            "New post",
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: SizedBox(
              width: parentWidth,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 25, right: 25, top: 15, bottom: 25),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ...photosList.map(
                              (photo) => Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: PhotoPreviewCard(
                                    width: thumbnailWidth,
                                    photo: Image(
                                      image: FileImage(photo),
                                      fit: BoxFit.cover,
                                    )),
                              ),
                            ),
                            AddNewPhotoCard(
                              width: thumbnailWidth,
                              parentState: this,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                                color: CustomColor.fifthBrown,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: TextField(
                              controller: controller,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                              minLines: 6,
                              maxLines: 6,
                              cursorColor: Colors.white,
                              decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.all(20),
                                  hintText: "Write your description here",
                                  hintStyle: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white38),
                                  focusColor: Colors.white,
                                  enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20)))),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ChooseRockDropdown(
                            controller: dropController,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const GetLocationCard(),
                          const SizedBox(
                            height: 20,
                          ),
                          CommonButton(
                            onPressed: addPost,
                            buttonText: "Send post",
                            backgroundColor: CustomColor.brownMostRecent,
                            textColor: Colors.white,
                            size: Size(parentWidth, 40),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
