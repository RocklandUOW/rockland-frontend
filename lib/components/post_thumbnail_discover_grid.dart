import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rockland/pages/post-screen/post.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/model.dart';

class GridViewThumbnail extends StatefulWidget {
  final Post post;

  const GridViewThumbnail({super.key, required this.post});

  @override
  State<GridViewThumbnail> createState() => _GridViewThumbnailState();
}

class _GridViewThumbnailState extends State<GridViewThumbnail> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Activity.startActivity(context, PostPage(post: widget.post)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
              image: CachedNetworkImageProvider(widget.post.pictureUrl[0]),
              fit: BoxFit.cover),
        ),
        height: 24,
      ),
    );
  }
}
