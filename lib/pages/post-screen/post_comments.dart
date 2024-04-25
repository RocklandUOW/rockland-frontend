import 'package:flutter/material.dart';
import 'package:rockland/styles/colors.dart';

class PostCommentPage extends StatelessWidget {
  const PostCommentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: CustomColor.mainBrown,
        child:  const SafeArea(
          child: Center(
            child: Column(
              children: [
                Text(
                  'Post Comments',
                  style: TextStyle(
                    color: Colors.white,
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}