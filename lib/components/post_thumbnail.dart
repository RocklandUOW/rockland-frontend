import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rockland/pages/post-screen/post.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:http/http.dart' as http;
import 'package:rockland/utility/user_provider.dart';

class PostThumbnail extends StatefulWidget {
  final Post post;

  const PostThumbnail({super.key, required this.post});

  @override
  State<PostThumbnail> createState() => _PostThumbnailState();
}

class _PostThumbnailState extends State<PostThumbnail> {
  User user = User();
  late Error error;
  late Error internalErr;

  bool isLoading = true;
  bool hasError = false;

  late String rockName;

  @override
  void initState() {
    super.initState();
    // this is a string extension defined in common.dart.
    // code by Dhruvil Patel on https://stackoverflow.com/a/76866369/25049731
    rockName = widget.post.rocktype.replaceAll("_", " ").capitalizeWord();
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
    return Consumer<UserProvider>(
      builder: (context, value, child) => InkWell(
        onTap: () => Activity.startActivity(
          context,
          PostPage(
            post: widget.post,
          ),
        ),
        child: Container(
          width: 200,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8))),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  color: Colors.transparent,
                  image: DecorationImage(
                      image:
                          CachedNetworkImageProvider(widget.post.pictureUrl[0]),
                      fit: BoxFit.cover),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    rockName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Icon(
                    widget.post.liked.contains(value.user.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.post.liked.contains(value.user.id)
                        ? Colors.redAccent
                        : Colors.white,
                    size: 18,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    widget.post.likedAmount.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                widget.post.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: CustomColor.fifthBrown,
                      border: Border.all(color: Colors.transparent),
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                    ),
                    clipBehavior: Clip.hardEdge,
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
                              size: 15,
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: isLoading || user.profilePictureUrl == ""
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
                                  color: CustomColor.extremelyLightBrown,
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
                    width: 5,
                  ),
                  Flexible(
                    child: AnimatedSize(
                      duration: Common.duration300,
                      curve: Curves.ease,
                      child: Text(
                        isLoading ? "" : "${user.firstName} ${user.lastName}",
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
