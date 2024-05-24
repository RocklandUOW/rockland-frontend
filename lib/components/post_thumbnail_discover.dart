import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rockland/pages/post-screen/post.dart';
import 'package:rockland/screens/image.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:http/http.dart' as http;
import 'package:rockland/utility/user_provider.dart';

class PostThumbnailDiscover extends StatefulWidget {
  final Post post;

  const PostThumbnailDiscover({super.key, required this.post});

  @override
  State<PostThumbnailDiscover> createState() => _PostThumbnailDiscoverState();
}

class _PostThumbnailDiscoverState extends State<PostThumbnailDiscover> {
  User user = User();
  late Error error;
  late Error internalErr;

  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
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
            body: jsonEncode(<String, String>{"id": widget.post.userId}));
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

  @override
  Widget build(BuildContext context) {
    double parentWidth = MediaQuery.of(context).size.width;

    return Consumer<UserProvider>(
      builder: (context, value, child) => InkWell(
        splashColor: Colors.white.withAlpha(20),
        highlightColor: Colors.white.withAlpha(20),
        onTap: () {
          Activity.startActivity(
              context,
              PostPage(
                post: widget.post,
                user: user,
              ));
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                          child: Row(
                        children: [
                          Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: CircleAvatar(
                              child: Stack(
                                children: [
                                  const Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    bottom: 0,
                                    child: Icon(
                                      Icons.person,
                                      size: 20,
                                    ),
                                  ),
                                  AnimatedOpacity(
                                    opacity: isLoading ||
                                            user.profilePictureUrl == ""
                                        ? 0
                                        : 1,
                                    duration: Common.duration300,
                                    child: CachedNetworkImage(
                                      imageUrl: isLoading ||
                                              user.profilePictureUrl == ""
                                          ? "https://static.vecteezy.com/system/resources/thumbnails/004/511/281/small/default-avatar-photo-placeholder-profile-picture-vector.jpg"
                                          : user.profilePictureUrl,
                                      fit: BoxFit.cover,
                                      progressIndicatorBuilder: (
                                        context,
                                        url,
                                        downloadProgress,
                                      ) {
                                        return CircularProgressIndicator(
                                          color:
                                              CustomColor.extremelyLightBrown,
                                          value: downloadProgress.progress,
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Flexible(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedSize(
                                duration: Common.duration300,
                                alignment: Alignment.topCenter,
                                curve: Curves.ease,
                                child: Text(
                                  isLoading
                                      ? ""
                                      : "${user.firstName} ${user.lastName}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ))
                        ],
                      )),
                      Row(
                        children: [
                          Text(
                            "1 Jan 1970",
                            style: TextStyle(color: Colors.white.withAlpha(80)),
                          )
                        ],
                      )
                    ],
                  ),
                  const AnimatedSize(
                    duration: Duration(milliseconds: 400),
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.ease,
                    child: Text(
                      widget.post.description,
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.white, height: 1.4),
                    ),
                  ),
                  const AnimatedSize(
                    duration: Duration(milliseconds: 400),
                    child: SizedBox(
                      height: 10,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Activity.startActivity(
                          context,
                          ViewImageExtended(
                            images: widget.post.pictureUrl,
                            user: user,
                          ));
                    },
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                              image: AssetImage("lib/images/LogoUpscaled.png")
                                  as ImageProvider,
                              fit: BoxFit.cover)),
                      width: parentWidth,
                      height: parentWidth,
                      child: AnimatedOpacity(
                        opacity: 1,
                        duration: Common.duration300,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: widget.post.pictureUrl[0],
                          progressIndicatorBuilder: (
                            context,
                            url,
                            downloadProgress,
                          ) {
                            return Wrap(
                              alignment: WrapAlignment.center,
                              runAlignment: WrapAlignment.center,
                              children: [
                                SizedBox(
                                  width: 30,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    color: CustomColor.extremelyLightBrown,
                                    value: downloadProgress.progress,
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 15),
              child: Row(
                children: [
                  Icon(
                    widget.post.liked.contains(value.user.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.post.liked.contains(value.user.id)
                        ? Colors.redAccent
                        : Colors.white,
                    size: 18,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    widget.post.likedAmount.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              width: parentWidth,
              height: 1,
              color: Colors.white.withAlpha(50),
            )
          ],
        ),
      ),
    );
  }
}
