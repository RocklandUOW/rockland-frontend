import 'package:flutter/material.dart';

class ResizeDragController {
  late void Function() showPopup;
}

class ResizeDrag extends StatefulWidget {
  final List<Widget>? children;
  final double maxHeight;
  final double middleHeight;
  final ResizeDragController? controller;

  static final GlobalKey<ResizeDragState> globalKey = GlobalKey();

  const ResizeDrag(
      {super.key,
      required this.middleHeight,
      required this.maxHeight,
      this.controller,
      this.children});

  @override
  State<ResizeDrag> createState() => ResizeDragState();
}

class ResizeDragState extends State<ResizeDrag> {
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
  double scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    widget.controller?.showPopup = showPopup;
    scrollController.addListener(() {
      scrollOffset = scrollController.offset;
      scrollEnabled = false;
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Stack(
      children: <Widget>[
        ...?widget.children,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
            height: height,
            width: width,
            color: Colors.red[100],
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25, top: 50),
                  child: GestureDetector(
                    child: Container(
                      color: Colors.white,
                      child: NotificationListener<ScrollEndNotification>(
                        child: ListView.builder(
                          controller: scrollController,
                          physics: scrollEnabled
                              ? const AlwaysScrollableScrollPhysics()
                              : const NeverScrollableScrollPhysics(),
                          itemCount: 50,
                          itemBuilder: (_, __) => const Text("data"),
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
                ),
                Expanded(
                  child: ManipulatingBall(
                    scrollController: scrollController,
                    onDragStart: (initialX, initialY) {
                      initialHeight = height;
                      initialWidth = width;
                    },
                    onDrag: (dx, dy) {
                      cumulativeDy -= dy;
                      var newHeight = height - dy;
                      setState(() {
                        if (scrollController.offset == 0) {
                          if (cumulativeDy > 0) {
                            scrollEnabled = true;
                          } else {
                            scrollEnabled = false;
                          }
                        }
                        previousHeight = height;
                        height = newHeight > 0 ? newHeight : 0;
                      });
                    },
                    onDragEnd: (finalX, finalY) {
                      if (cumulativeDy < -150) {
                        setState(() {
                          height = 0;
                        });
                      } else if (cumulativeDy > 30) {
                        setState(() {
                          height = widget.middleHeight;
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

class ManipulatingBall extends StatefulWidget {
  final Function(double initialX, double initialY) onDragStart;
  final Function(double dx, double dy) onDrag;
  final Function(double finalX, double finalY) onDragEnd;
  final ScrollController scrollController;

  const ManipulatingBall(
      {super.key,
      required this.onDragStart,
      required this.onDrag,
      required this.onDragEnd,
      required this.scrollController});

  @override
  _ManipulatingBallState createState() => _ManipulatingBallState();
}

class _ManipulatingBallState extends State<ManipulatingBall> {
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
