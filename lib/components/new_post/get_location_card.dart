import 'package:flutter/material.dart';
import 'package:rockland/pages/gmaps.dart';
import 'package:rockland/styles/colors.dart';

class GetLocationCard extends StatefulWidget {
  final Color backgroundColor;

  const GetLocationCard({
    super.key,
    this.backgroundColor = CustomColor.brownMostRecent,
  });

  @override
  State<GetLocationCard> createState() => _GetLocationCardState();
}

class _GetLocationCardState extends State<GetLocationCard> {
  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double parentWidth = mediaQuery.size.width;

    return Container(
      width: parentWidth,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const CircleAvatar(
                child: Icon(
                  Icons.place,
                  color: CustomColor.mainBrown,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              const Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Keiraville",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "NSW, 2500",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              )),
              IgnorePointer(
                child: Container(
                  width: 100,
                  height: 100,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: const GMapsPage(),
                ),
              )
            ],
          )),
    );
  }
}
