import 'dart:async';
import 'package:flutter/material.dart';
import 'package:premades_nn/utils/ColorUtil.dart';

// ignore: must_be_immutable
class NetLoadingDialog extends StatefulWidget {
  String loadingText;
  bool outsideDismiss;
  Function dismissCallback;
  Future<dynamic> requestCallBack;
  static bool isDismiss = false;

  NetLoadingDialog(
      {Key key,
      this.loadingText = "loading...",
      this.outsideDismiss = true,
      this.dismissCallback,
      this.requestCallBack})
      : super(key: key);

  @override
  State<NetLoadingDialog> createState() => _LoadingDialog();

  static void showLoadingDialog(BuildContext context, String loadingText, {Function dismissCallback}){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return new NetLoadingDialog(
            outsideDismiss: false,
            loadingText: loadingText,
            dismissCallback: dismissCallback,
          );
        });
  }

  static void dismiss(BuildContext context){
    if (!isDismiss){
      Navigator.pop(context);
    }
  }
}



class _LoadingDialog extends State<NetLoadingDialog> {
  _dismissDialog() {
    if (widget.dismissCallback != null) {
      widget.dismissCallback();
      NetLoadingDialog.isDismiss = true;
    }
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    if (widget.requestCallBack != null) {
      widget.requestCallBack.then((_) {
        Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: widget.outsideDismiss ? _dismissDialog : null,
      child: Material(
        type: MaterialType.transparency,
        child: new Center(
          child: new SizedBox(
            width: 200.0,
            height: 150.0,
            child: new Container(
              decoration: ShapeDecoration(
                color: Color(0xffffffff),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
              ),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new CircularProgressIndicator(
                    backgroundColor: ColorUtil.nnBlue,
                  ),
                  new Padding(
                    padding: const EdgeInsets.only(
                      top: 20.0,
                    ),
                    child: new Text(
                      widget.loadingText,
                      style: new TextStyle(fontSize: 12.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


}