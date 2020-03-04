import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/utils/ColorUtil.dart';

///点击效果按钮 ----背景颜色为渐变类型
class ClickButton extends StatefulWidget {
  double width;

  double height;

  String text;

  Color textColor;

  double textSize;

  EdgeInsets margin;

  LinearGradient gradientNormal;

  LinearGradient gradientClick;

  BorderRadius borderRadius;

  Function clickCallback;

  ClickButton(
      {this.text,
      this.width,
      this.height,
      this.clickCallback,
      this.textColor,
      this.textSize,
      this.gradientNormal,
      this.gradientClick,
      this.borderRadius,
      this.margin}) {
    assert(text != null, "Button text not null");
    assert(width != null, "Button width not null");
    assert(height != null, "Button height not null");
    assert(clickCallback != null, "Button click Callback not null");

    if (gradientNormal == null) {
      gradientNormal = LinearGradient(colors: [
        ColorUtil.btnStartColor,
        ColorUtil.btnEndColor,
      ], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    }

    if (gradientClick == null) {
      gradientClick = LinearGradient(colors: [
        ColorUtil.btnEndColor,
        ColorUtil.btnEndColor,
      ], begin: Alignment.topCenter, end: Alignment.bottomCenter);
    }

    if (borderRadius == null) {
      borderRadius = BorderRadius.all(Radius.circular(25));
    }

    if (textColor == null) {
      textColor = ColorUtil.white;
    }

    if (textSize == null) {
      textSize = ScreenUtil().setSp(18);
    }
  }

  @override
  _ClickButtonState createState() => _ClickButtonState();
}

class _ClickButtonState extends State<ClickButton> {
  int _clickStatus;

  LinearGradient _gradient;

  @override
  Widget build(BuildContext context) {
    if (_clickStatus == ClickStatus.clickDown) {
      _gradient = widget.gradientClick;
    } else {
      _gradient = widget.gradientNormal;
    }

    if (widget.margin == null) {
      widget.margin = EdgeInsets.all(0);
    }

    return Listener(
      onPointerDown: (downDetail) {
        setState(() {
          _clickStatus = ClickStatus.clickDown;
        });
      },
      onPointerUp: (upDetail) {
        setState(() {
          _clickStatus = ClickStatus.clickUp;
        });

        widget.clickCallback();
      },
      child: Container(
        alignment: Alignment.center,
        margin: widget.margin,
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: _gradient,
            boxShadow: <BoxShadow>[
              //设置阴影
              BoxShadow(
                offset: Offset(0, 5),
                color: ColorUtil.shadow, //阴影颜色
                blurRadius: 5, //阴影大小
              ),
            ]),
        child: Text(widget.text,
            style:
                TextStyle(color: widget.textColor, fontSize: widget.textSize)),
      ),
    );
  }
}

class ClickStatus {
  static const int clickDown = 0;

  static const int clickUp = 1;
}
