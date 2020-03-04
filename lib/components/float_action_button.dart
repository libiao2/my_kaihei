import 'package:flutter/material.dart';
import 'dart:math' as math;
class PageFloating extends StatefulWidget {
  @override
  _PageFloatingState createState() {
    return _PageFloatingState();
  }
}

class _PageFloatingState extends State<PageFloating> {
  int progress = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: GuideUserActionLocation.getInstance(),
      floatingActionButton: Container(
        child: Text('-'),
      ),
    );
  }
}
class GuideUserActionLocation extends FloatingActionButtonLocation {
  double marginRight = 20;
  double marginBottom = 30;
  GuideUserActionLocation._();

  static GuideUserActionLocation _instance;

  static GuideUserActionLocation getInstance() {
    if (_instance == null) {
      _instance = GuideUserActionLocation._();
    }
    return _instance;
  }

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    // Compute the x-axis offset.
    final double fabX = _endOffset(scaffoldGeometry);

    // Compute the y-axis offset.
    final double contentBottom = scaffoldGeometry.contentBottom;
    final double bottomSheetHeight = scaffoldGeometry.bottomSheetSize.height;
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height;
    final double snackBarHeight = scaffoldGeometry.snackBarSize.height;

    double fabY = contentBottom - fabHeight - marginBottom;
    if (snackBarHeight > 0.0)
      fabY = math.min(
          fabY,
          contentBottom -
              snackBarHeight -
              fabHeight -
              kFloatingActionButtonMargin);
    if (bottomSheetHeight > 0.0)
      fabY =
          math.min(fabY, contentBottom - bottomSheetHeight - fabHeight / 2.0);
    return Offset(fabX, fabY);
  }

  @override
  String toString() => 'TestActionLocation';

  double _endOffset(ScaffoldPrelayoutGeometry scaffoldGeometry,
      {double offset = 0.0}) {
    assert(scaffoldGeometry.textDirection != null);
    switch (scaffoldGeometry.textDirection) {
      case TextDirection.rtl:
        return _leftOffset(scaffoldGeometry, offset: offset);
      case TextDirection.ltr:
        return _rightOffset(scaffoldGeometry, offset: offset);
    }
    return null;
  }

  double _leftOffset(ScaffoldPrelayoutGeometry scaffoldGeometry,
      {double offset = 0.0}) {
    return kFloatingActionButtonMargin +
        scaffoldGeometry.minInsets.left -
        offset;
  }

  double _rightOffset(ScaffoldPrelayoutGeometry scaffoldGeometry,
      {double offset = 0.0}) {
    return scaffoldGeometry.scaffoldSize.width -
        scaffoldGeometry.floatingActionButtonSize.width -
        marginRight;
  }
}