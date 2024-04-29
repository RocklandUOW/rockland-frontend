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

  double initialX = 0;
  double initialY = 0;

  double cumulativeDy = 0;
  double cumulativeDx = 0;
  double cumulativeMid = 0;

  bool scrollEnabled = false;
  bool isDragging = false;
  double scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    widget.controller?.showPopup = showPopup;
    widget.controller?.hidePopup = hidePopup;
    scrollController.addListener(() {
      scrollOffset = scrollController.offset;
      scrollEnabled = false;
    });
    setState(() {
      height = widget.minHeight;
    });
  }

  bool checkScrollOffset() {
    if (scrollController.hasClients) {
      return scrollController.offset > 0;
    }
    return true;
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

  @override
  Widget build(BuildContext context) {
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
            child: Stack(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Container(
                        width: 75,
                        height: 5,
                        decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: widget.padding!,
                      child: Container(
                        color: widget.listBgColor,
                        child: Padding(
                          padding: widget.padding!,
                          child: NotificationListener<ScrollEndNotification>(
                            child: ListView(
                              physics: scrollEnabled
                                  ? const AlwaysScrollableScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                              children: [
                                ...?widget.children,
                              ],
                            ),
                            onNotification: (notification) {
                              if (scrollController.position.pixels == 0.0) {
                                setState(() {
                                  scrollEnabled = false;
                                });
                              }
                              return true;
                            },
                          ),
                        ),
                      ),
                    ))
                  ],
                ),
                ContainerDragDetector(
                  scrollController: scrollController,
                  onDragStart: (initialX, initialY) {
                    if (!widget.enableDrag!) {
                      return;
                    }
                    initialHeight = height;
                    initialWidth = width;
                  },
                  onDrag: (dx, dy) {
                    if (!widget.enableDrag!) {
                      return;
                    }
                    cumulativeDy -= dy;
                    var newHeight = height - dy;
                    setState(() {
                      isDragging = true;
                      if (scrollController.hasClients) {
                        if (scrollController.position.pixels == 0.0) {
                          if (cumulativeDy > 0) {
                            scrollEnabled = true;
                          } else {
                            scrollEnabled = false;
                          }
                        }
                      }
                      previousHeight = height;
                      if (height > widget.maxHeight) {
                        height = widget.maxHeight;
                      } else {
                        height = newHeight > 0 ? newHeight : 0;
                      }
                    });
                  },
                  onDragEnd: (finalX, finalY) {
                    if (!widget.enableDrag!) {
                      return;
                    }
                    setState(() {
                      isDragging = false;
                    });
                    if (cumulativeDy < -30) {
                      setState(() {
                        if (height > widget.middleHeight) {
                          height = widget.middleHeight;
                        } else {
                          height = widget.minHeight;
                        }
                        // reset listview scroll position
                        if (scrollController.hasClients) {
                          scrollController.jumpTo(0);
                        }
                      });
                    } else if (cumulativeDy > 30) {
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
                  },
                ),
              ],
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
  final ScrollController scrollController;

  const ContainerDragDetector(
      {super.key,
      required this.onDragStart,
      required this.onDrag,
      required this.onDragEnd,
      required this.scrollController});

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
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: _handleDrag,
      onPanEnd: _handleDragEnd,
      onPanUpdate: _handleUpdate,
      child: IgnorePointer(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}
