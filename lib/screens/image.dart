import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/model.dart';
import 'package:rockland/utility/physics.dart';

class ViewImageExtended extends StatefulWidget {
  final List<dynamic> images;
  final User? user;
  final int page;

  const ViewImageExtended({
    super.key,
    required this.images,
    this.user,
    this.page = 0,
  });

  @override
  State<ViewImageExtended> createState() => _ViewImageExtendedState();
}

class _ViewImageExtendedState extends State<ViewImageExtended> {
  late PageController galleryController;

  bool _enablePaging = true;
  bool isDynamicList = false;
  List<String> credit = [];
  List<dynamic> images = [];
  String currentCredit = "";

  @override
  void initState() {
    super.initState();

    galleryController = PageController(initialPage: widget.page);

    for (dynamic image in widget.images) {
      Widget child;
      if (image is Map<String, dynamic>) {
        RockImages imageData = RockImages.fromJson(image);
        credit.add(imageData.credit); // if image is rock view
        if (imageData.link.contains("http")) {
          child = CachedNetworkImage(
            imageUrl: imageData.link,
            progressIndicatorBuilder: (
              context,
              url,
              downloadProgress,
            ) {
              return Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      color: CustomColor.extremelyLightBrown,
                      value: downloadProgress.progress,
                    ),
                  )
                ],
              );
            },
          );
        } else {
          child = Image.file(
            File(imageData.link),
          );
        }
        isDynamicList = true;
      } else {
        child = CachedNetworkImage(
          imageUrl: image,
          progressIndicatorBuilder: (
            context,
            url,
            downloadProgress,
          ) {
            return Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              children: [
                SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    color: CustomColor.extremelyLightBrown,
                    value: downloadProgress.progress,
                  ),
                )
              ],
            );
          },
        );
        credit.add("${widget.user!.firstName} ${widget.user!.lastName}");
      }
      images.add(child);
    }
    currentCredit = credit[widget.page];
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double parentWidth = mediaQuery.size.width;
    double parentHeight = mediaQuery.size.height;
    double safeAreaPadding = mediaQuery.padding.top;

    return Scaffold(
      backgroundColor: CustomColor.mainBrown,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: CustomColor.mainBrown,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 15, right: 15, top: 20 + safeAreaPadding),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () => Activity.finishActivity(context),
                      style:
                          IconButton.styleFrom(foregroundColor: Colors.white),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    child: Text(
                      "© $currentCredit",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Flexible(
            child: PageView.builder(
              controller: galleryController,
              onPageChanged: (index) {
                setState(() {
                  currentCredit = credit[index];
                });
              },
              physics: _enablePaging
                  ? const CustomPageViewScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return Container(
                  width: parentWidth,
                  height: parentHeight,
                  color: CustomColor.mainBrown,
                  child: DoubleTappableInteractiveViewer(
                    onScaleChanged: (scale) {
                      setState(() {
                        _enablePaging = scale <= 1.0;
                      });
                    },
                    scaleDuration: Common.duration250,
                    maxZoomScale: 5,
                    maxZoomedAmount: 1,
                    child: images[index],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class DoubleTappableInteractiveViewer extends StatefulWidget {
  final double scale;
  final Duration scaleDuration;
  final Curve curve;
  final Widget child;
  final double maxZoomedAmount;
  final double maxZoomScale;
  final double incrementZoom;
  final Function(double scale)? onScaleChanged;

  const DoubleTappableInteractiveViewer({
    super.key,
    this.scale = 2,
    this.curve = Curves.fastLinearToSlowEaseIn,
    this.maxZoomedAmount = 1,
    this.maxZoomScale = 15,
    this.incrementZoom = 2,
    this.onScaleChanged,
    required this.scaleDuration,
    required this.child,
  });

  @override
  State<DoubleTappableInteractiveViewer> createState() =>
      _DoubleTappableInteractiveViewerState();
}

class _DoubleTappableInteractiveViewerState
    extends State<DoubleTappableInteractiveViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Animation<Matrix4>? _zoomAnimation;
  late TransformationController _transformationController;
  late TransformationController _transformationControllerScaleHolder;
  TapDownDetails? _doubleTapDetails;
  late double zoomedAmount;
  late double currentZoom;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationControllerScaleHolder = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.scaleDuration,
    )..addListener(() {
        _transformationController.value = _zoomAnimation!.value;
      });
    zoomedAmount = 0;
    currentZoom = widget.incrementZoom;
  }

  @override
  void dispose() {
    _transformationControllerScaleHolder.dispose();
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    late Matrix4 newValue;
    print("memek");
    print(_transformationController.value.getMaxScaleOnAxis());
    print(_transformationController.value.getMaxScaleOnAxis() <= 1.0);
    if (zoomedAmount < widget.maxZoomedAmount &&
        _transformationController.value.getMaxScaleOnAxis() <= 1.0) {
      if (zoomedAmount == widget.maxZoomedAmount - 1) {
        newValue = _applyZoom(widget.maxZoomScale);
      } else {
        newValue = _applyZoom(currentZoom);
      }
      zoomedAmount += 1;
      currentZoom += widget.incrementZoom;
    } else {
      newValue = _revertZoom();
      zoomedAmount = 0;
      currentZoom = widget.incrementZoom;
    }

    _transformationControllerScaleHolder.value = newValue;

    _zoomAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: newValue,
    ).animate(CurveTween(curve: widget.curve).animate(_animationController));
    _animationController.forward(from: 0);

    if (widget.onScaleChanged != null) {
      widget.onScaleChanged!(
          _transformationControllerScaleHolder.value.getMaxScaleOnAxis());
    }
  }

  Matrix4 _applyZoom(double scale) {
    final tapPosition = _doubleTapDetails!.localPosition;
    final x = -tapPosition.dx * (scale - 1);
    final y = -tapPosition.dy * (scale - 1);
    final zoomed = Matrix4.identity()
      ..translate(x, y)
      ..scale(scale);
    return zoomed;
  }

  Matrix4 _revertZoom() {
    return Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        maxScale: widget.maxZoomScale,
        transformationController: _transformationController,
        onInteractionEnd: (details) {
          double scale = _transformationController.value.getMaxScaleOnAxis();
          if (widget.onScaleChanged != null) {
            widget.onScaleChanged!(scale);
          }
        },
        child: widget.child,
      ),
    );
  }
}
