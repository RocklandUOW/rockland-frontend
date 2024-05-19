import 'package:flutter/material.dart';
import 'package:rockland/styles/colors.dart';

class PhotoPreviewCard extends StatelessWidget {
  final double width;
  final Widget photo;

  const PhotoPreviewCard({super.key, required this.width, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width,
      decoration: const BoxDecoration(
          color: CustomColor.fifthBrown,
          borderRadius: BorderRadius.all(Radius.circular(8))),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: photo,
          ),
          Positioned(
            right: 10,
            top: 10,
            child: GestureDetector(
              child: const CircleAvatar(
                backgroundColor: CustomColor.extremelyLightBrown,
                maxRadius: 16,
                child: Icon(
                  Icons.close,
                  size: 16,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
