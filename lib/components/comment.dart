import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rockland/components/alert_dialog.dart';
import 'package:rockland/pages/post-screen/post_comments.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:http/http.dart' as http;
import 'package:rockland/utility/strings.dart';
import 'package:rockland/utility/user_provider.dart';

class CommentCard extends StatefulWidget {
  final Comment commentData;
  final PostCommentPageState parentState;

  const CommentCard(
      {super.key, required this.commentData, required this.parentState});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  User user = User();

  late Error error;
  late Error internalErr;

  bool isLoading = true;
  bool hasError = false;

  // confirmation dialogs
  late DismissableAlertDialog deleteDialog;
  late DismissableAlertDialog loadingDialog;

  @override
  void initState() {
    super.initState();
    loadingDialog = LoadingDialog.construct(context);

    deleteDialog = DismissableAlertDialog(
        context: context,
        child: const Text("Are you sure you want to delete this comment?"));
    deleteDialog.setCancelButton(TextButton(
        onPressed: () => deleteDialog.dismiss(), child: const Text("No")));
    deleteDialog.setOkButton(TextButton(
        onPressed: () async {
          deleteDialog.dismiss();
          loadingDialog.show();
          await deleteComment();
          widget.parentState.refresh();
        },
        child: const Text("Yes")));
    getUser();
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
              "id": widget.commentData.userId,
            }));
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> userDetails = jsonDecode(response.body);
        setState(() {
          user = User.fromJson(userDetails);
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

  Future<void> deleteComment() async {
    print("called");
    if (isLoading) return;
    print("called again");
    isLoading = true;
    const url =
        "https://rockland-app-service.onrender.com/delete_comment/";
    try {
      http.Response response;
      try {
        response = await http.delete(
          Uri.parse(url),
          headers: <String, String>{"Content-Type": "application/json"},
          body: jsonEncode(
            <String, String>{
              "id": widget.commentData.id,
            },
          ),
        );
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        print(response.body);
        setState(() {
          isLoading = false;
          loadingDialog.dismiss();
          widget.parentState.result
              .setChild(const Text("Comment was deleted successfully"));
          widget.parentState.result.show();
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
    final double safeAreaPadding = mediaQuery.padding.top;
    final double parentWidth = mediaQuery.size.width;
    final double parentHeight = mediaQuery.size.height;
    final double middleHeight = parentHeight / 2 + 100;
    final double maxHeight = parentHeight - safeAreaPadding;

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "${user.firstName} ${user.lastName}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Flexible(
                          // TODO: PROPERLY FORMAT THIS
                            child: Text(
                          // widget.commentData.timestamp,
                          " · 1m",
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white.withAlpha(80),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      widget.commentData.comment,
                      style: CommonStyles.commonTextStyle,
                    ),
                  ],
                ),
              ),
              Opacity(
                opacity: value.user.id == widget.commentData.userId ? 1 : 0,
                child: GestureDetector(
                  onTap: () {
                    if (value.user.id == widget.commentData.userId) {
                      deleteDialog.show();
                    }
                  },
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 20,
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
