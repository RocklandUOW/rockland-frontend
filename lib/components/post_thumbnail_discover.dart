import 'package:flutter/material.dart';
import 'package:rockland/pages/post-screen/post.dart';
import 'package:rockland/screens/image.dart';
import 'package:rockland/utility/activity.dart';

class PostThumbnailDiscover extends StatefulWidget {
  const PostThumbnailDiscover({super.key});

  @override
  State<PostThumbnailDiscover> createState() => _PostThumbnailDiscoverState();
}

class _PostThumbnailDiscoverState extends State<PostThumbnailDiscover> {
  @override
  Widget build(BuildContext context) {
    double parentWidth = MediaQuery.of(context).size.width;

    return InkWell(
      splashColor: Colors.white.withAlpha(20),
      highlightColor: Colors.white.withAlpha(20),
      onTap: () {
        Activity.startActivity(context, const PostPage());
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                        child: Row(
                      children: [
                        CircleAvatar(
                          child: Icon(
                            Icons.person,
                            size: 20,
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Flexible(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "John",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
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
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "I found this Ruby while hiking on Mount Everest. Cool looking stone ain't gonna lie.",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () {
                    Activity.startActivity(context, ViewImageExtended());
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
                  ),
                )
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
    );
  }
}
