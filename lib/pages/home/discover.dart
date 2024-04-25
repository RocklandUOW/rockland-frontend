import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  Location locationController = Location();
  static const LatLng googlePlex = LatLng(37.4223, -122.0848);
  static const LatLng googlePlex2 = LatLng(37.4223, -122.1248);
  static const LatLng googlePlex3 = LatLng(37.3923, -122.0848);
  static const LatLng applePlex = LatLng(37.3346, -122.0090);
  LatLng? currentPos;
  late StreamSubscription<LocationData> locationChangedListener;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  void dispose() {
    try {
      locationChangedListener.cancel();
    } catch (e) {}
    super.dispose();
  }

  void handleTap() {
    Future.delayed(const Duration(milliseconds: 200), () {
      showDialog(
          context: context,
          builder: (context) {
            return const Dialog(
              elevation: 16,
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Text("Show uploaded rock info here\n"
                    "Show uploaded rock info here"),
              ),
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentPos == null
          ? const Center(
              child: Text("Loading..."),
            )
          : SafeArea(
              child: Expanded(
                  child: GoogleMap(
              initialCameraPosition:
                  const CameraPosition(target: googlePlex, zoom: 13),
              markers: {
                Marker(
                  markerId: const MarkerId("currentLoc"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: googlePlex,
                  onTap: handleTap,
                ),
                Marker(
                  markerId: const MarkerId("currentLoc2"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: googlePlex2,
                  onTap: handleTap,
                ),
                Marker(
                  markerId: const MarkerId("currentLoc3"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: googlePlex3,
                  onTap: handleTap,
                ),
                Marker(
                  markerId: const MarkerId("destLoc"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: applePlex,
                  onTap: handleTap,
                ),
              },
            ))),
    );
  }

  Future<void> getLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await locationController.serviceEnabled();
    if (serviceEnabled) {
      serviceEnabled = await locationController.requestService();
    } else {
      // TODO: handle error here relating to the service being unavailable.
      return;
    }

    permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        // TODO: handle error here informing the user that they need to grant loc perm.
        return;
      }
    }

    locationChangedListener =
        locationController.onLocationChanged.listen((LocationData currentLoc) {
      if (currentLoc.latitude != null &&
          currentLoc.longitude != null &&
          mounted) {
        setState(() {
          currentPos = LatLng(currentLoc.latitude!, currentLoc.longitude!);
        });
      }
    });
  }
}
