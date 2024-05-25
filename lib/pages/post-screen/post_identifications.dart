import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rockland/components/alert_dialog.dart';
import 'package:rockland/components/identification.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/pages/post-screen/post.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:http/http.dart' as http;
import 'package:rockland/utility/strings.dart';
import 'package:rockland/utility/user_provider.dart';

class PostIdentificationsPage extends StatefulWidget {
  final PostPageState parentState;

  const PostIdentificationsPage({super.key, required this.parentState});

  @override
  State<PostIdentificationsPage> createState() =>
      PostIdentificationsPageState();
}

class PostIdentificationsPageState extends State<PostIdentificationsPage> {
  // identifications
  bool isGridView = false;
  bool isLoading = false;
  bool hasMorePosts = true;
  bool hasError = false;
  bool requestNext = false;
  int currentPostPage = 1;
  late Error error;
  late Error internalErr;
  List<Identification> posts = [];

  // already verified check
  bool userAlreadyVerified = false;
  Identification? prevVerif;

  // post identification
  bool isPostIdentificationLoading = false;

  // rock
  bool isRockLoading = true;
  bool rockHasError = false;
  late Error internalRockErr;
  List<Rock> rocks = [];

  // dropdown
  String dropDownValue = "null";

  // confirmation dialog
  late DismissableAlertDialog resultDialog;
  late DismissableAlertDialog deleteDialog;
  late DismissableAlertDialog loadingDialog;

  @override
  void initState() {
    super.initState();
    getPosts();
    getRockInfo();
    resultDialog =
        DismissableAlertDialog(context: context, child: const Text(""));
    resultDialog.setOkButton(TextButton(
        onPressed: () => resultDialog.dismiss(), child: const Text("OK")));

    loadingDialog = LoadingDialog.construct(context);

    deleteDialog = DismissableAlertDialog(
        context: context,
        child:
            const Text("Are you sure you want to delete your verification?"));
    deleteDialog.setCancelButton(TextButton(
        onPressed: () => deleteDialog.dismiss(), child: const Text("No")));
    deleteDialog.setOkButton(TextButton(
        onPressed: () async {
          deleteDialog.dismiss();
          loadingDialog.show();
          await deleteVerification();
          refresh();
        },
        child: const Text("Yes")));
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> getPosts() async {
    if (isLoading || !hasMorePosts) return;
    isLoading = true;
    const url =
        "https://rockland-app-service.onrender.com/get_verifications_by_post_id/";
    try {
      http.Response response;
      try {
        response = await http.post(
          Uri.parse(url),
          headers: <String, String>{"Content-Type": "application/json"},
          body: jsonEncode(
            <String, String>{
              "id": widget.parentState.widget.post.id,
            },
          ),
        );
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        final List postsNextPage = jsonDecode(response.body);
        setState(() {
          isLoading = false;
          currentPostPage += 1;
          posts.addAll(postsNextPage.map((post) {
            return Identification.fromJson(post);
          }).toList());
          hasMorePosts = false;
          requestNext = false;
        });
      } else {
        throw internalErr = Error(
          errorCode: response.statusCode,
          description:
              "A server error has occured on the discover service. Status code is as stated.",
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = false;
        hasMorePosts = false;
        print(e.toString());
        // to display to the user.
        // error = ErrorBuilder.build(internalErr.errorCode);
      });
    }
  }

  Future<void> deleteVerification() async {
    print("called");
    if (isLoading) return;
    print("called again");
    isLoading = true;
    const url =
        "https://rockland-app-service.onrender.com/delete_verification/";
    try {
      http.Response response;
      try {
        response = await http.delete(
          Uri.parse(url),
          headers: <String, String>{"Content-Type": "application/json"},
          body: jsonEncode(
            <String, String>{
              "id": prevVerif!.id,
            },
          ),
        );
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
          loadingDialog.dismiss();
          resultDialog
              .setChild(const Text("Verification was deleted successfully"));
          resultDialog.show();
        });
      } else {
        throw internalErr = Error(
          errorCode: response.statusCode,
          description:
              "A server error has occured on the discover service. Status code is as stated.",
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = false;
        hasMorePosts = false;
        print(e.toString());
        // to display to the user.
        // error = ErrorBuilder.build(internalErr.errorCode);
      });
    }
  }

  void refresh() {
    setState(() {
      hasMorePosts = true;
      hasError = false;
      posts.clear();
      userAlreadyVerified = false;
    });
    getPosts();
  }

  Future<bool> postIdentification(User user) async {
    const url = "https://rockland-app-service.onrender.com/add_verification/";
    String message = "";
    if (dropDownValue == "null") {
      message = "Please select a rock before posting your verification";
    } else if (userAlreadyVerified) {
      message =
          "You have already verified this rock before. You will have to delete your previous verification if you want to do so.";
    }
    if (message != "") {
      setState(() {
        resultDialog.setCancelButton(null);
        resultDialog.setChild(
          Text(message),
        );
        if (message.contains("verified this rock")) {
          resultDialog.setCancelButton(TextButton(
              onPressed: () {
                resultDialog.dismiss();
                resultDialog.setCancelButton(null);
                deleteDialog.show();
              },
              child: const Text("Delete previous verification")));
        }
        resultDialog.show();
      });
      return false;
    }
    setState(() {
      isPostIdentificationLoading = true;
      // loadingDialog.show();
    });
    try {
      http.Response response;
      try {
        response = await http.post(Uri.parse(url),
            headers: <String, String>{"Content-Type": "application/json"},
            body: jsonEncode(<String, dynamic>{
              "post_id": widget.parentState.widget.post.id,
              "user_id": user.id,
              "verification": dropDownValue,
              "agree": [user.id],
              "timestamp": "2024-05-18T09:55:46.948Z",
              "disagree": []
            }));
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        setState(() {
          isPostIdentificationLoading = false;
          // loadingDialog.dismiss();
          resultDialog.setChild(
            const Text("Verification was added successfully"),
          );
          // resultDialog.show();
        });
        return true;
      } else {
        throw internalErr = Error(
          errorCode: response.statusCode,
          description:
              "A server error has occured on the discover service. Status code is as stated.",
        );
      }
    } catch (e) {
      setState(() {
        loadingDialog.dismiss();
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
      });
    }
    return false;
  }

  void getRockInfo() async {
    setState(() {
      isRockLoading = true;
    });
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
        List<dynamic> getResult = jsonDecode(req.body);
        setState(() {
          for (dynamic rock in getResult) {
            rocks.add(Rock.fromJson(rock));
          }
          isRockLoading = false;
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
    } catch (e) {
      setState(() {
        isRockLoading = false;
        rockHasError = false;
        if (e is Error) {
          print((e as Error).errorCode);
          print((e as Error).description);
        } else {
          print(e.toString());
        }
        // to display to the user.
        // error = ErrorBuilder.build(internalErr.errorCode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double safeAreaPadding = mediaQuery.padding.top;
    final double parentWidth = mediaQuery.size.width;
    final double parentHeight = mediaQuery.size.height;
    final double middleHeight = parentHeight / 2 + 100;
    final double maxHeight = parentHeight - safeAreaPadding;

    return Consumer<UserProvider>(
      builder: (context, value, child) => PopUpContainer(
        minHeight: 0,
        middleHeight: middleHeight,
        maxHeight: maxHeight,
        controller: widget.parentState.verificationController,
        containerBgColor: CustomColor.mainBrown,
        listBgColor: CustomColor.mainBrown,
        topChildren: [
          Container(
            width: parentWidth,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: CustomColor.fifthBrown),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                "Rock identification and verification",
                textAlign: TextAlign.center,
                style: CommonStyles.commonTextStyle,
              ),
            ),
          )
        ],
        bottomChildren: [
          Container(
            width: parentWidth,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: CustomColor.fifthBrown),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 15,
                top: 15,
                left: 18,
                right: 18,
              ),
              child: value.user.id == ""
                  ? const Center(
                      child: Text(
                        "Sign in to add verification",
                        style: TextStyle(
                          color: Colors.white38,
                        ),
                      ),
                    )
                  : Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: CustomColor.fifthBrown,
                            border: Border.all(color: Colors.transparent),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100)),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: CircleAvatar(
                            child: value.user.profilePictureUrl == ""
                                ? const Icon(
                                    Icons.person,
                                    size: 20,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: value.user.profilePictureUrl,
                                    fit: BoxFit.cover,
                                    progressIndicatorBuilder: (
                                      context,
                                      url,
                                      downloadProgress,
                                    ) {
                                      return CircularProgressIndicator(
                                        color: CustomColor.extremelyLightBrown,
                                        value: downloadProgress.progress,
                                      );
                                    }),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Container(
                          decoration: const BoxDecoration(
                              color: CustomColor.fifthBrown,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: DropdownButton<String>(
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: "Lato",
                                  color: Colors.white),
                              dropdownColor: CustomColor.fifthBrown,
                              iconEnabledColor: Colors.white,
                              isExpanded: true,
                              value: dropDownValue,
                              onChanged: (value) {
                                setState(() {
                                  dropDownValue = value!;
                                });
                              },
                              underline: Container(
                                height: 0,
                              ),
                              items: <DropdownMenuItem<String>>[
                                const DropdownMenuItem(
                                  value: "null",
                                  child: Text(
                                    "Select a rock that matches",
                                  ),
                                ),
                                ...rocks.map(
                                  (rockData) => DropdownMenuItem(
                                    value: rockData.name,
                                    child: Text(
                                      rockData.rock["name"],
                                      style: CommonStyles.commonTextStyle,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: CustomColor.fifthBrown,
                            border: Border.all(color: Colors.transparent),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(100)),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: CircleAvatar(
                            child: IconButton(
                              onPressed: () async {
                                setState(() {
                                  dropDownValue == "null";
                                });
                                final res =
                                    await postIdentification(value.user);
                                if (res) {
                                  refresh();
                                }
                              },
                              icon: const Icon(
                                Icons.send,
                                size: 20,
                                color: CustomColor.mainBrown,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
            ),
          )
        ],
        children: [
          SingleChildScrollView(
            child: Column(
              children: isLoading
                  ? [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 160),
                        child: Text(
                          "Loading...",
                          style: TextStyle(
                            color: Colors.white38,
                          ),
                        ),
                      )
                    ]
                  : posts.isEmpty
                      ? [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 160),
                            child: Text(
                              "No verifications yet",
                              style: TextStyle(
                                color: Colors.white38,
                              ),
                            ),
                          )
                        ]
                      : [
                          ...posts.map(
                            (identificationData) => IdentificationCard(
                              identificationData: identificationData,
                              parentState: this,
                            ),
                          )
                        ],
            ),
          )
        ],
      ),
    );
  }
}
