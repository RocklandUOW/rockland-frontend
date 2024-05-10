import 'package:flutter/material.dart';
import 'package:rockland/pages/post-screen/post.dart';
import 'package:rockland/utility/activity.dart';

class PostThumbnail extends StatefulWidget {
  const PostThumbnail({super.key});

  @override
  State<PostThumbnail> createState() => _PostThumbnailState();
}

class _PostThumbnailState extends State<PostThumbnail> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Activity.startActivity(context, const PostPage()),
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
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: Colors.transparent,
                image: DecorationImage(
                    image: AssetImage("lib/images/LogoUpscaled.png")
                        as ImageProvider,
                    fit: BoxFit.cover),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Ruby",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "I found this Ruby while hiking on Mount Everest. Cool looking stone ain't gonna lie.",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(
              height: 10,
            ),
            const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    child: Icon(
                      Icons.person,
                      size: 15,
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Flexible(
                    child: Text(
                  "John",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white),
                ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
