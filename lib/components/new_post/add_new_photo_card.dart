import 'package:flutter/material.dart';
import 'package:rockland/screens/newpost.dart';
import 'package:rockland/styles/colors.dart';

class AddNewPhotoCard extends StatelessWidget {
  final double width;
  final NewPostScreenState parentState;

  const AddNewPhotoCard({
    super.key,
    required this.width,
    required this.parentState,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => parentState.takePhoto(),
      child: Container(
        width: width,
        height: width,
        decoration: const BoxDecoration(
            color: CustomColor.fifthBrown,
            borderRadius: BorderRadius.all(Radius.circular(8))),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: CustomColor.extremelyLightBrown,
              size: 40,
            ),
            Text(
              "Add a new photo",
              style: TextStyle(color: CustomColor.extremelyLightBrown),
            )
          ],
        ),
      ),
    );
  }
}
