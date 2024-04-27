import 'package:flutter/material.dart';
import 'package:rockland/pages/gmaps.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';

class PostInfoPage extends StatelessWidget {
  const PostInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: CustomColor.mainBrown,
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                // map bar
                Container(
                  color: CustomColor.quarternaryBrown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(children: [
                      // place icon
                      const Expanded(
                        flex: 1,
                        child: Icon(
                          Icons.place,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),

                      // Place information (text)
                      const Expanded(
                        flex: 8,
                        child: Column(children: [
                          Text('Place Name',
                              style: TextStyle(color: Colors.white)),
                          Text('State, Postcode',
                              style: TextStyle(color: Colors.white)),
                        ]),
                      ),

                      // spacer
                      const Spacer(),

                      // map picture / Button
                      InkWell(
                        onTap: () =>
                            Activity.startActivity(context, new GMapsPage()),
                        child: const Placeholder(
                          child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Center(
                              child: Text(
                                "gmap preview",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] // map bar
                        ),
                  ),
                ),

                // Description
                Container(
                    color: CustomColor.tertiaryBrown,
                    child: const Center(
                        child: Text('Description Here',
                            style: TextStyle(
                              color: Colors.white,
                            )))),
              ], // main body
            ),
          ),
        ),
      ),
    );
  }
}
