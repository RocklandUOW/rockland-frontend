import 'package:flutter/material.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/strings.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CameraPageBuilder {
  static List<Widget> whenLoading() {
    return [
      Expanded(child: Container()),
      const Text(
        "Identifying",
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(
        height: 15,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Text(
          RockIdentificationStrings.identifying,
          style: CommonStyles.commonTextStyle,
        ),
      ),
      const SizedBox(
        height: 15,
      ),
      const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          color: CustomColor.extremelyLightBrown,
          strokeWidth: 3,
        ),
      ),
      Expanded(child: Container()),
    ];
  }

  static List<Widget> whenFirstOpened() {
    return [
      Expanded(child: Container()),
      Text(
        "Opening camera",
        style: CommonStyles.commonTextStyle,
      ),
      const SizedBox(
        height: 15,
      ),
      const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          color: CustomColor.extremelyLightBrown,
          strokeWidth: 3,
        ),
      ),
      Expanded(child: Container())
    ];
  }

  static List<Widget> whenNotIdentified(Function takePhoto) {
    return [
      Expanded(child: Container()),
      const Text(
        "We couldn't find a match 🙏",
        style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(
        height: 15,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
        ),
        child: Text(
          RockIdentificationStrings.notIdentified,
          style: CommonStyles.commonTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(
        height: 15,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
              onPressed: () => takePhoto(),
              icon: const Icon(
                Icons.camera_alt,
                color: CustomColor.fifthBrown,
              ),
              label: Text(
                CommonStrings.tryAgain,
                style: CommonStyles.mainBrownText,
              )),
          const SizedBox(
            width: 15,
          ),
          ElevatedButton.icon(
              onPressed: () async =>
                  await launchUrlString("mailto:${CommonStrings.email}"),
              icon: const Icon(
                Icons.email,
                color: CustomColor.fifthBrown,
              ),
              label: Text(
                CommonStrings.contactUs,
                style: CommonStyles.mainBrownText,
              )),
        ],
      ),
      Expanded(child: Container()),
    ];
  }
}
