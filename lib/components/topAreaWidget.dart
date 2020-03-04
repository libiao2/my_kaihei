import 'package:flutter/material.dart';
import 'dart:math' as math;

class TopAreaWidget extends StatelessWidget {
  final Widget child; //布局
  final Color color; //背景颜色

  TopAreaWidget({@required this.child, this.color = Colors.blueGrey});

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = MediaQuery.of(context).padding;
    double top = math.max(padding.top, EdgeInsets.zero.top); //计算状态栏的高度

    return Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: top,
          // color: color,
          color: Color.fromRGBO(245, 245, 245, 0.3),
        ),
        Expanded(child: child),
      ],
    );
  }
}
