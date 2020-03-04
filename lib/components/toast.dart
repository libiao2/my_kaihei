import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Widget toast(title) {
  Fluttertoast.showToast(
    msg: title,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIos: 1,
    backgroundColor: Colors.black54,
    textColor: Colors.white,
    fontSize: 16.0
  );
}