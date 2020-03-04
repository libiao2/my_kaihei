import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/utils/ColorUtil.dart';

class MyTextField extends StatefulWidget {
  Function callBack;

  String hintNormal;

  String hintClick;

  bool obscureText;

  List<TextInputFormatter> inputFormatters;

  TextEditingController controller;

  TextInputType textInputType;

  MyTextField({this.controller,
    this.callBack,
    this.hintClick,
    this.hintNormal,
    this.obscureText,
    this.inputFormatters,
    this.textInputType})
      : assert(controller != null),
        assert(hintClick != null),
        assert(hintNormal != null),
        assert(obscureText != null),
        assert(textInputType != null);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  FocusNode _focusNode = FocusNode();

  String hint;

  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      setState(() {
        if (!_focusNode.hasFocus) {
          _hasFocus = false;
        } else {
          _hasFocus = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if ((widget.controller.text != null && widget.controller.text != "") ||
        _hasFocus) {
      hint = widget.hintClick;
    } else {
      hint = widget.hintNormal;
    }

    return Container(
      alignment: Alignment.centerLeft,
      child: TextField(
        onTap: () {
          if (widget.callBack != null) {
            widget.callBack();
          }
        },
        obscureText: widget.obscureText,
        inputFormatters: widget.inputFormatters,
        focusNode: _focusNode,
        cursorColor: ColorUtil.black,
        controller: widget.controller,
        keyboardType: widget.textInputType,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(left: ScreenUtil().setHeight(10)),
            border: InputBorder.none,
            labelText: hint,
            labelStyle: TextStyle(
                color: ColorUtil.greyHint, fontSize: ScreenUtil().setSp(18))),
        autofocus: false,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(
          width: ScreenUtil().setHeight(0.5),
          color: _hasFocus?ColorUtil.nnBlue:ColorUtil.greyHint
        ))
      ),
    );

  }
}
