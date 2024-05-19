import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rockland/components/alert_dialog.dart';
import 'package:rockland/components/comment.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/pages/post-screen/post.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:http/http.dart' as http;
import 'package:rockland/utility/user_provider.dart';

class PostCommentPage extends StatefulWidget {
  final PostPageState parentState;

  const PostCommentPage({super.key, required this.parentState});

  @override
  State<PostCommentPage> createState() => PostCommentPageState();
}

class PostCommentPageState extends State<PostCommentPage> {
  // comments
  bool isGridView = false;
  bool isLoading = false;
  bool hasMorePosts = true;
  bool hasError = false;
  bool requestNextComment = false;
  int currentPostPage = 1;
  late Error error;
  late Error internalErr;
  List<Comment> posts = [];

  // post comment
  bool isPostCommentLoading = false;

  // confirmation dialog
  late DismissableAlertDialog result;

  // textfield controller
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    getPosts();
    result = DismissableAlertDialog(context: context, child: const Text(""));
    result.setOkButton(
        TextButton(onPressed: () => result.dismiss(), child: const Text("OK")));
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
        "https://rockland-app-service.onrender.com/get_comments_by_post_id/";
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
            return Comment.fromJson(post);
          }).toList());
          hasMorePosts = false;
          requestNextComment = false;
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

  Future<void> postComment(User user, String comment) async {
    const url = "https://rockland-app-service.onrender.com/add_comment/";
    setState(() {
      isPostCommentLoading = true;
    });
    try {
      http.Response response;
      try {
        response = await http.post(Uri.parse(url),
            headers: <String, String>{"Content-Type": "application/json"},
            body: jsonEncode(<String, String>{
              "post_id": widget.parentState.widget.post.id,
              "user_id": user.id,
              "timestamp": "2024-05-18T10:19:00.698Z",
              "comment": comment
            }));
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        setState(() {
          isPostCommentLoading = false;
          result.setChild(
            const Text("Comment was added successfully"),
          );
          // result.show();
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

  void refresh() {
    setState(() {
      hasMorePosts = true;
      hasError = false;
      requestNextComment = true;
      posts.clear();
    });
    getPosts();
  }

  loadPostsWorker() async {
    while (true) {
      print("background task lol");
      if (!requestNextComment) {
        break;
      }
      await getPosts();
      await Future.delayed(const Duration(milliseconds: 500));
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

    // COMMENT POPUP CONTAINER
    return Consumer<UserProvider>(
      builder: (context, value, child) => PopUpContainer(
        minHeight: 0,
        middleHeight: middleHeight,
        maxHeight: maxHeight,
        controller: widget.parentState.commentsController,
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
                "Comments",
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
                        "Sign in to add a comment",
                        style: TextStyle(color: Colors.white38),
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
                        Flexible(
                            child: Container(
                          decoration: const BoxDecoration(
                              color: CustomColor.fifthBrown,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              TextField(
                                controller: controller,
                                onSubmitted: (comment) {
                                  controller.clear();
                                  postComment(value.user, comment)
                                      .then((_) => refresh());
                                },
                                textInputAction: TextInputAction.send,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                                decoration: const InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(
                                        top: 11,
                                        bottom: 11,
                                        left: 20,
                                        right: 20),
                                    hintText: "Write your comment",
                                    hintStyle: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white38),
                                    focusColor: Colors.white,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.transparent),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)))),
                              ),
                            ],
                          ),
                        ))
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
                              "No comments yet",
                              style: TextStyle(
                                color: Colors.white38,
                              ),
                            ),
                          )
                        ]
                      : [
                          ...posts.map(
                            (commentData) => CommentCard(
                              commentData: commentData,
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
