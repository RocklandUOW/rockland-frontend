// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as location;
import 'package:permission_handler/permission_handler.dart' as permission;
import 'package:rockland/components/alert_dialog.dart';
import 'package:rockland/pages/post-screen/post.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:rockland/utility/rest_operations/post.dart';
import 'package:rockland/utility/strings.dart';

class GMapsPage extends StatefulWidget {
  final List<Post>? posts;
  final bool isDiscover;

  const GMapsPage({
    super.key,
    this.posts,
    this.isDiscover = false,
  });

  @override
  State<GMapsPage> createState() => _GMapsPageState();
}

class _GMapsPageState extends State<GMapsPage> {
  location.Location locationController = location.Location();
  final Completer<GoogleMapController> mapController =
      Completer<GoogleMapController>();

  // static const LatLng googlePlex = LatLng(37.4223, -122.0848);
  // static const LatLng googlePlex2 = LatLng(37.4223, -122.1248);
  // static const LatLng googlePlex3 = LatLng(37.3923, -122.0848);
  // static const LatLng applePlex = LatLng(37.3346, -122.0090);
  late LatLng currentPos;
  late StreamSubscription<location.LocationData> locationChangedListener;

  bool isLoading = false;
  bool locationChangedListenerSubscribed = false;

  User defaultUser = User(firstName: "User", lastName: "Account");
  User currentUser = User(firstName: "User", lastName: "Account");

  late DismissableAlertDialog loading;
  late DismissableAlertDialog permissionDeniedDialog;

  List<Post> posts = [];
  Post placeholder = Post.fromJson({
    "_id": "664860ab128efa5aade1ccd2",
    "rocktype": "pyrite",
    "picture_url": [
      "https://firebasestorage.googleapis.com/v0/b/rockland-c14ac.appspot.com/o/664860aa128efa5aade1ccd1post_image?alt=media"
    ],
    "description": "found this andesite on UOW building 41",
    "latitude": -34.407149,
    "longitude": 150.878416,
    "hashtags": ["memek1", "memek2", "memek3", "memek4"],
    "liked": [],
    "timestamp": "2024-05-18T08:02:51.087000",
    "liked_amount": 0,
    "user_id": "66486058128efa5aade1ccd0"
  });

  @override
  void initState() {
    super.initState();
    if (widget.posts != null) {
      posts.addAll(widget.posts!);
    } else {
      posts.add(placeholder);
    }

    if (widget.isDiscover) {
      getPostsByRadius();
    }

    currentPos = const LatLng(-34.407149, 150.878416);

    loading = LoadingDialog.construct(context);

    permissionDeniedDialog = DismissableAlertDialog(
      context: context,
      child: const Text(PermissionStrings.locationServiceDenied),
      okButton: TextButton(
        onPressed: () {
          permissionDeniedDialog.dismiss();
        },
        child: const Text("OK"),
      ),
    );
  }

  @override
  void dispose() {
    if (locationChangedListenerSubscribed) {
      locationChangedListener.cancel();
    }
    super.dispose();
  }

  Future<void> getUser(String userId) async {
    setState(() {
      currentUser = defaultUser;
    });
    User? userGet = await PostOperations.getUser(userId);
    setState(() {
      if (userGet != null) {
        currentUser = userGet;
      }
    });
  }

  Future<void> getPostsByRadius() async {
    await getLocation();
    final postsByRadius = await PostOperations.getPostsByRadiusKm(
      currentPos.latitude,
      currentPos.longitude,
    );
    setState(() {
      posts.addAll(postsByRadius);
    });
  }

  void goToPost(int postIndexFromList) {
    Widget postPage = PostPage(post: posts[postIndexFromList]);
    Activity.startActivity(context, postPage);
    // try {
    //   if (history[history.length - 1] is PostPage) {
    //     // 2 times because showing dialog is considered a "new activity"
    //     Activity.finishActivity(context);
    //     Activity.finishActivity(context);
    //   } else {
    //     Activity.startActivity(context, postPage);
    //   }
    // } catch (e) {
    //   Activity.startActivity(context, postPage);
    // }
  }

  void handleTap(int postIndexFromList) {
    Future.delayed(const Duration(milliseconds: 200), () async {
      loading.show();
      await getUser(posts[postIndexFromList].userId);
      loading.dismiss();
      showDialog(
          context: context,
          builder: (context) {
            final MediaQueryData mediaQuery = MediaQuery.of(context);
            final double parentWidth = mediaQuery.size.width;
            return GestureDetector(
              onTap: () => {
                if (widget.isDiscover) {goToPost(postIndexFromList)}
              },
              child: Dialog(
                elevation: 16,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: SizedBox(
                    width: parentWidth,
                    height: 130,
                    child: Row(
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            color: CustomColor.mainBrown,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          width: 130,
                          height: 130,
                          clipBehavior: Clip.hardEdge,
                          child: CachedNetworkImage(
                            imageUrl: posts[postIndexFromList].pictureUrl[0],
                            fit: BoxFit.cover,
                            progressIndicatorBuilder: (
                              context,
                              url,
                              downloadProgress,
                            ) {
                              return CircularProgressIndicator(
                                color: CustomColor.extremelyLightBrown,
                                value: downloadProgress.progress,
                              );
                            },
                          ),
                        ),
                        Expanded(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              posts[postIndexFromList]
                                  .rocktype
                                  .replaceAll("_", " ")
                                  .capitalizeWord(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    clipBehavior: Clip.hardEdge,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: CircleAvatar(
                                      maxRadius: 15,
                                      child: Stack(
                                        children: [
                                          const Positioned(
                                            left: 0,
                                            right: 0,
                                            top: 0,
                                            bottom: 0,
                                            child: Icon(
                                              Icons.person,
                                              size: 15,
                                            ),
                                          ),
                                          AnimatedOpacity(
                                            opacity:
                                                currentUser.profilePictureUrl ==
                                                        ""
                                                    ? 0
                                                    : 1,
                                            duration: Common.duration300,
                                            child: CachedNetworkImage(
                                              imageUrl: currentUser
                                                          .profilePictureUrl ==
                                                      ""
                                                  ? "https://static.vecteezy.com/system/resources/thumbnails/004/511/281/small/default-avatar-photo-placeholder-profile-picture-vector.jpg"
                                                  : currentUser
                                                      .profilePictureUrl,
                                              fit: BoxFit.cover,
                                              progressIndicatorBuilder: (
                                                context,
                                                url,
                                                downloadProgress,
                                              ) {
                                                return CircularProgressIndicator(
                                                  color: CustomColor
                                                      .extremelyLightBrown,
                                                  value:
                                                      downloadProgress.progress,
                                                );
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    "${currentUser.firstName} ${currentUser.lastName}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )
                              ],
                            )
                          ],
                        ))
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: widget.isDiscover
          ? Stack(
              children: [
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: FloatingActionButton(
                    backgroundColor: CustomColor.extremelyLightBrown,
                    tooltip: 'Move camera to current location',
                    onPressed: () => cameraToPosition(currentPos),
                    child: const Icon(Icons.my_location,
                        color: CustomColor.mainBrown, size: 28),
                  ),
                )
              ],
            )
          : null,
      body: GoogleMap(
        onMapCreated: (controller) => mapController.complete(controller),
        zoomControlsEnabled: false,
        initialCameraPosition: CameraPosition(
            target: widget.isDiscover
                ? LatLng(currentPos.latitude, currentPos.longitude)
                : LatLng(posts[0].latitude, posts[0].longitude),
            zoom: 15),
        circles: widget.isDiscover
            ? {
                Circle(
                  circleId: CircleId("currentLocCircle"),
                  // fillColor: Colors.blue.withAlpha(80),
                  strokeColor: Colors.blue,
                  center: currentPos,
                  radius: 10,
                ),
                Circle(
                  circleId: CircleId("currentLocCircleRadius"),
                  fillColor: Colors.blue.withAlpha(40),
                  strokeColor: Colors.transparent,
                  center: currentPos,
                  radius: 3000,
                ),
                Circle(
                  circleId: CircleId("currentLocCircleRadiusTwo"),
                  fillColor: Colors.blue.withAlpha(80),
                  strokeColor: Colors.transparent,
                  center: currentPos,
                  radius: 100,
                ),
              }
            : {},
        markers: {
          ...posts.mapIndexed((index, post) {
            return Marker(
              markerId: MarkerId("posts_loc_${index}"),
              icon: BitmapDescriptor.defaultMarker,
              position: LatLng(post.latitude, post.longitude),
              onTap: () => handleTap(index),
            );
          }),
        },
      ),
    );
  }

  Future<void> cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await mapController.future;
    CameraPosition newCameraPosition = CameraPosition(
      target: pos,
      zoom: 14,
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(newCameraPosition),
    );
  }

  void setDeniedDialogAndShow(bool isPermissionDenied) {
    Widget child;
    permissionDeniedDialog.setCancelButton(null);
    if (isPermissionDenied) {
      child = const Text(PermissionStrings.locationServiceDenied);
      permissionDeniedDialog.setCancelButton(TextButton(
        onPressed: () async {
          await permission.openAppSettings();
        },
        child: const Text("Go to settings"),
      ));
    } else {
      child = const Text(PermissionStrings.requestLocationEnable);
    }
    permissionDeniedDialog.setChild(child);
    permissionDeniedDialog.show();
  }

  Future<void> getLocation() async {
    bool serviceEnabled;
    location.PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (serviceEnabled) {
      serviceEnabled = await locationController.requestService();
    } else {
      setDeniedDialogAndShow(false);
      return;
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == location.PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != location.PermissionStatus.granted) {
        setDeniedDialogAndShow(true);
        return;
      }
    }

    locationChangedListenerSubscribed = true;
    locationChangedListener = locationController.onLocationChanged
        .listen((location.LocationData currentLoc) {
      if (currentLoc.latitude != null &&
          currentLoc.longitude != null &&
          mounted) {
        setState(() {
          LatLng previousPos = currentPos;
          currentPos = LatLng(currentLoc.latitude!, currentLoc.longitude!);

          final distanceMetres = Geolocator.distanceBetween(
            previousPos.latitude,
            previousPos.longitude,
            currentPos.latitude,
            currentPos.longitude,
          );

          // if distance is greater than 100 metres then refresh
          if (distanceMetres > 100) {
            getPostsByRadius();
            cameraToPosition(currentPos);
          }
        });
      }
    });
  }
}
