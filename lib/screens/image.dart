import 'package:flutter/material.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/physics.dart';

class ViewImageExtended extends StatefulWidget {
  const ViewImageExtended({super.key});

  @override
  State<ViewImageExtended> createState() => _ViewImageExtendedState();
}

class _ViewImageExtendedState extends State<ViewImageExtended> {
  bool _enablePaging = true;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    double parentWidth = mediaQuery.size.width;
    double parentHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: CustomColor.mainBrown,
      appBar: AppBar(
        // page title
        title: const Text('',
            style: TextStyle(
              color: Colors.white,
            )),
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body: PageView.builder(
        physics: _enablePaging
            ? const CustomPageViewScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        itemCount: 3,
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
              child: Image.asset("lib/images/LogoUpscaled.png"),
            ),
          );
        },
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
