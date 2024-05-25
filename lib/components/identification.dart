import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rockland/pages/post-screen/post_identifications.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/model.dart';
import 'package:http/http.dart' as http;
import 'package:rockland/utility/user_provider.dart';

class IdentificationCard extends StatefulWidget {
  final Identification identificationData;
  final PostIdentificationsPageState parentState;

  const IdentificationCard({
    super.key,
    required this.identificationData,
    required this.parentState,
  });

  @override
  State<IdentificationCard> createState() => IdentificationCardState();
}

class IdentificationCardState extends State<IdentificationCard> {
  User user = User();
  User currentUser = User();

  late Error error;
  late Error internalErr;

  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userState = context.read<UserProvider>();
      currentUser = userState.user;
      getUser();
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void getUser() async {
    const url = "https://rockland-app-service.onrender.com/get_account_by_id/";
    isLoading = true;
    try {
      http.Response response;
      try {
        response = await http.post(Uri.parse(url),
            headers: <String, String>{"Content-Type": "application/json"},
            body: jsonEncode(<String, String>{
              "id": widget.identificationData.userId,
            }));
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> userDetails = jsonDecode(response.body);
        setState(() {
          user = User.fromJson(userDetails);
          if (user.id == currentUser.id) {
            widget.parentState.userAlreadyVerified = true;
            widget.parentState.prevVerif = widget.identificationData;
          }
          isLoading = false;
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

  Future<void> agreeDisagreeVerification(bool agree) async {
    if (isLoading) return;
    isLoading = true;
    String url;
    if (agree) {
      url =
          "https://rockland-app-service.onrender.com/add_verification_agree_to_verification/";
    } else {
      url =
          "https://rockland-app-service.onrender.com/add_verification_disagree_to_verification/";
    }

    try {
      http.Response response;
      try {
        response = await http.put(
          Uri.parse(url),
          headers: <String, String>{"Content-Type": "application/json"},
          body: jsonEncode(
            <String, String>{
              "verification_id": widget.identificationData.id,
              "user_id": currentUser.id
            },
          ),
        );
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
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
        print(e.toString());
        // to display to the user.
        // error = ErrorBuilder.build(internalErr.errorCode);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double parentWidth = mediaQuery.size.width;

    return Consumer<UserProvider>(
      builder: (context, value, child) => Padding(
        padding: const EdgeInsets.all(18),
        child: SizedBox(
          width: parentWidth,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: CustomColor.fifthBrown,
                  border: Border.all(color: Colors.transparent),
                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                ),
                clipBehavior: Clip.hardEdge,
                child: CircleAvatar(
                  child: user.profilePictureUrl == ""
                      ? const Icon(
                          Icons.person,
                          size: 20,
                        )
                      : CachedNetworkImage(
                          imageUrl: user.profilePictureUrl,
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
                width: 15,
              ),
              Flexible(
                  child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      text: "",
                      style: const TextStyle(
                        height: 1.5,
                        color: Colors.white,
                        fontFamily: "Lato",
                      ),
                      children: <TextSpan>[
                        TextSpan(
                            text: "${user.firstName} ${user.lastName}"
                                .replaceAll("_", " "),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(
                          text: ' suggested that ',
                        ),
                        TextSpan(
                            text: widget.identificationData.verification
                                .replaceAll("_", " "),
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(
                          text: " is the type of rock in this post",
                        ),
                        // TODO: PROPERLY SET THE TIMESTAMP (VERIFICATION)
                        TextSpan(
                          // text: widget.identificationData.timestamp,
                          text: "  · 1m",
                          style: TextStyle(
                            color: Colors.white.withAlpha(80),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: widget.identificationData.disagree
                                .contains(currentUser.id)
                            ? Colors.redAccent
                            : CustomColor.fifthBrown,
                        child: IconButton(
                            onPressed: () {
                              if (value.user.id != "") {
                                agreeDisagreeVerification(false).then(
                                    (value) => widget.parentState.refresh());
                              } else {
                                widget.parentState.resultDialog.setChild(
                                    const Text(
                                        "Sign in to disagree to this suggestion"));
                                widget.parentState.resultDialog.show();
                              }
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            )),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        widget.identificationData.disagreeAmount.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      CircleAvatar(
                        backgroundColor: widget.identificationData.agree
                                .contains(currentUser.id)
                            ? Colors.green
                            : CustomColor.fifthBrown,
                        child: IconButton(
                          onPressed: () {
                            if (value.user.id != "") {
                              agreeDisagreeVerification(true).then(
                                  (value) => widget.parentState.refresh());
                            } else {
                              widget.parentState.resultDialog.setChild(
                                  const Text(
                                      "Sign in to agree to this suggestion"));
                              widget.parentState.resultDialog.show();
                            }
                          },
                          icon: const Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        widget.identificationData.agreeAmount.toString(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  )
                ],
              )),
              Opacity(
                opacity:
                    currentUser.id == widget.identificationData.userId ? 1 : 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, top: 3),
                  child: GestureDetector(
                    onTap: () {
                      if (currentUser.id == widget.identificationData.userId) {
                        widget.parentState.deleteDialog.show();
                      }
                    },
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
