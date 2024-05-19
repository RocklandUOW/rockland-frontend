import 'package:flutter/material.dart';
import 'package:rockland/pages/post-screen/post.dart';

class PostButtons extends StatefulWidget {
  final PostPageState parentState;
  final IconData icon;
  final Color color;
  final Function() onPress;

  const PostButtons(
      {super.key,
      required this.parentState,
      required this.onPress,
      required this.icon,
      this.color = Colors.white});

  @override
  State<PostButtons> createState() => _PostButtonsState();
}

class _PostButtonsState extends State<PostButtons> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent),
          borderRadius: const BorderRadius.all(Radius.circular(100))),
      child: IconButton(
        style: IconButton.styleFrom(foregroundColor: Colors.white),
        onPressed: widget.onPress,
        icon: Icon(
          widget.icon,
          color: widget.color,
        ),
      ),
    );
  }
}
