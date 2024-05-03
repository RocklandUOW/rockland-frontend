import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/*
This is a modified version of Ehsaneha's code on Stack overflow to call the
child widget's functions from the parent class.
https://stackoverflow.com/questions/53692798/flutter-calling-child-class-function-from-parent-class
*/
class PopUpContainerController {
  late void Function() showPopup;
  late void Function() hidePopup;
}

/*
This is a modified version of Kherel's, Ishtar's, and Seth's codes on Stack overflow. 
link: https://stackoverflow.com/questions/60924384/creating-resizable-view-that
-resizes-when-pinch-or-drag-from-corners-and-sides-i
*/
class PopUpContainer extends StatefulWidget {
  final List<Widget>? children;
  final PopUpContainerController? controller;
  final double minHeight;
  final double middleHeight;
  final double maxHeight;
  final int? dragSmoothness;
  final int? animationDuration;
  final bool? enableDrag;
  final bool? enableHideOnTapShadow;
  final EdgeInsets? padding;
  final Color? containerBgColor;
  final Color? listBgColor;
  final Color? shadowBgColor;

  const PopUpContainer(
      {super.key,
      required this.minHeight,
      required this.middleHeight,
      required this.maxHeight,
      this.controller,
      this.children,
      this.enableDrag = true,
      this.enableHideOnTapShadow = true,
      this.padding = EdgeInsets.zero,
      this.dragSmoothness = 80,
      this.animationDuration = 250,
      this.containerBgColor = Colors.white,
      this.listBgColor = Colors.white30,
      this.shadowBgColor = Colors.black26});

  @override
  State<PopUpContainer> createState() => PopUpContainerState();
}

class PopUpContainerState extends State<PopUpContainer> {
  ScrollController scrollController = ScrollController(initialScrollOffset: 0);

  double initialHeight = 0;
  double initialWidth = 0;

  double previousHeight = 0;
  double previousWidth = 0;

  double height = 0;
  double width = 200;

  double cumulativeDy = 0;

  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.showPopup = showPopup;
    widget.controller?.hidePopup = hidePopup;
    setState(() {
      height = widget.minHeight;
    });
  }

  void showPopup() {
    setState(() {
      height = widget.middleHeight;
    });
  }

  void hidePopup() {
    setState(() {
      height = 0;
    });
  }

  void onDragStart(initialX, initialY) {
    if (!widget.enableDrag!) {
      return;
    }
    initialHeight = height;
    initialWidth = width;
  }

  void onDrag(dx, dy,
      {canMaximise = true, canMinimise = true, canMinimiseWhenever = false}) {
    if (!widget.enableDrag!) {
      return;
    }
    cumulativeDy -= dy;
    var newHeight = height - dy;

    // prevents "Build scheduled during frame" error
    if (cumulativeDy > 0 && !canMaximise) {
      return;
    }

    if (cumulativeDy < 0) {
      // prevents drag speed being multiplied cause of overlapping
      // or container being dragged down when listview is scrolled down
      // and position is not 0
      if (!canMinimise || scrollController.position.pixels != 0.0) {
        if (!canMinimiseWhenever) {
          return;
        }
      }
    }

    setState(() {
      isDragging = true;
      previousHeight = height;
      if (height > widget.maxHeight) {
        height = widget.maxHeight;
      } else {
        height = newHeight > 0 ? newHeight : 0;
      }
    });
  }

  void onDragEnd(finalX, finalY) {
    if (!widget.enableDrag!) {
      return;
    }
    setState(() {
      isDragging = false;
    });
    if (cumulativeDy < -100) {
      // prevents container being dragged down when list
      // view is scrolled down and position is not 0
      setState(() {
        if (height > widget.middleHeight) {
          height = widget.middleHeight;
        } else {
          height = widget.minHeight;
          // reset listview scroll position
          scrollController.jumpTo(0.0);
        }
      });
    } else if (cumulativeDy > 100) {
      setState(() {
        if (height > widget.middleHeight) {
          height = widget.maxHeight;
        } else {
          height = widget.middleHeight;
        }
      });
    } else {
      setState(() {
        height = initialHeight;
      });
    }
    cumulativeDy = 0;
    initialHeight = height;
    initialWidth = width;
  }

  @override
  Widget build(BuildContext context) {
    final parentWidth = MediaQuery.of(context).size.width;

    return SafeArea(
        child: Stack(
      children: <Widget>[
        GestureDetector(
          behavior: height > widget.minHeight
              ? HitTestBehavior.opaque
              : HitTestBehavior.translucent,
          onTap: height > widget.minHeight
              ? widget.enableHideOnTapShadow!
                  ? hidePopup
                  : null
              : null,
          child: IgnorePointer(
            ignoring: true,
            child: AnimatedOpacity(
              opacity: height > widget.minHeight ? 1 : 0,
              duration: Duration(milliseconds: widget.animationDuration!),
              child: Container(
                color: widget.shadowBgColor,
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedContainer(
            duration: Duration(
                milliseconds: isDragging
                    ? widget.dragSmoothness!
                    : widget.animationDuration!),
            curve: Curves.ease,
            height: height,
            width: width,
            decoration: BoxDecoration(
                color: widget.containerBgColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            child: ContainerDragDetector(
              onDragStart: onDragStart,
              onDrag: (dx, dy) => {onDrag(dx, dy, canMaximise: false)},
              onDragEnd: onDragEnd,
              child: Column(
                children: [
                  ContainerDragDetector(
                    onDragStart: onDragStart,
                    onDrag: (dx, dy) => {
                      onDrag(dx, dy,
                          canMinimise: false,
                          canMinimiseWhenever:
                              scrollController.position.pixels != 0.0
                                  ? true
                                  : false)
                    },
                    onDragEnd: onDragEnd,
                    child: SizedBox(
                      width: parentWidth,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 170),
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Padding(
                    padding: widget.padding!,
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          color: widget.listBgColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      child: Padding(
                        padding: widget.padding!,
                        child: ListView(
                          controller: scrollController,
                          children: [
                            ...?widget.children,
                          ],
                        ),
                      ),
                    ),
                  ))
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }
}

const ballDiameter = 30.0;

class ContainerDragDetector extends StatefulWidget {
  final Function(double initialX, double initialY) onDragStart;
  final Function(double dx, double dy) onDrag;
  final Function(double finalX, double finalY) onDragEnd;
  final Widget? child;

  const ContainerDragDetector(
      {super.key,
      required this.onDragStart,
      required this.onDrag,
      required this.onDragEnd,
      this.child});

  @override
  _ContainerDragDetectorState createState() => _ContainerDragDetectorState();
}

class _ContainerDragDetectorState extends State<ContainerDragDetector> {
  late double initX;
  late double initY;

  _handleDrag(details) {
    setState(() {
      initX = details.globalPosition.dx;
      initY = details.globalPosition.dy;
      widget.onDragStart(initX, initY);
    });
  }

  _handleDragEnd(details) {
    widget.onDragEnd(initX, initY);
  }

  _handleUpdate(details) {
    var dx = details.globalPosition.dx - initX;
    var dy = details.globalPosition.dy - initY;
    initX = details.globalPosition.dx;
    initY = details.globalPosition.dy;
    widget.onDrag(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: {
        AllowMultipleVerticalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
                AllowMultipleVerticalDragGestureRecognizer>(
          () => AllowMultipleVerticalDragGestureRecognizer(),
          (AllowMultipleVerticalDragGestureRecognizer instance) {
            instance.onStart = _handleDrag;
            instance.onUpdate = _handleUpdate;
            instance.onEnd = _handleDragEnd;
          },
        )
      },
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}

// Credit to Nash0x7E2 for making the code and Niklas Raab
// for pointing it out that this existed. Respective links:
// https://gist.github.com/Nash0x7E2/08acca529096d93f3df0f60f9c034056
// https://stackoverflow.com/questions/58138114/receive-onverticaldragupdate
// -on-nested-gesturedetectors-in-flutter
class AllowMultipleVerticalDragGestureRecognizer
    extends VerticalDragGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}
