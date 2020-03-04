import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';




Future request(type, url, formData) async{

  if (!Constants.connected){
    toast("网络异常，请查看网络连接状态！");
    return "网络异常，请查看网络连接状态！";
  }

  try{
    Response response;

    var options = BaseOptions(
      connectTimeout: 15000,
      receiveTimeout: 15000,
    );

    Dio dio = new Dio(options);
    // 请求头
    dio.options.contentType = ContentType.parse('application/json');

    //Req-Client-Type:
    //    ClientTypePC      = 1 // PC
    //    ClientTypeAndroid = 2 // Android
    //    ClientTypeIOS     = 3 // IOS
    //    ClientTypeMac     = 4 // Mac
    //    ClientTypeWeb     = 5 // web
    

     if (Constants.token != null && Constants.token != "") {
       dio.options.headers = {
         "Authorization": "Bearer " + Constants.token,
         'NN-Client-Type': Platform.isIOS ? 3 : 2,
       };
     } else {
       dio.options.headers = {
         'NN-Client-Type': Platform.isIOS ? 3 : 2,
       };
     }

    print("请求前--------地址：$url\t 参数： $formData");

    if(type == 'post') {
      if(formData == null) {
        response = await dio.post(url);
      } else {
        response = await dio.post(url, data: formData);
      }
    } else if(type == 'get') {
      if(formData == null) {
        response = await dio.get(url);
      } else {
        response = await dio.get(url, queryParameters: formData);
      }
    } else if (type == 'put'){
      if(formData == null) {
        response = await dio.put(url);
      } else {
        response = await dio.put(url, data: formData);
      }
    } else if (type == 'del'){
      if(formData == null) {
        response = await dio.delete(url);
      } else {
        response = await dio.delete(url, data: formData);
      }
    } else {
      return "请求类型错误";
    }

    var myResponse = jsonDecode(response.toString());
    print('结果：$myResponse');
//    if (myResponse == null || myResponse['code'] != 0) {
//      Fluttertoast.showToast(
//          msg: myResponse['msg'],
//          toastLength: Toast.LENGTH_SHORT,
//          gravity: ToastGravity.CENTER,
//          timeInSecForIos: 1,
//          backgroundColor: Colors.black54,
//          textColor: Colors.white,
//          fontSize: 16.0
//      );
//    }
    return myResponse;
  }catch(e){
    return print('${e}');
  }
}

_getToken(){
  Future<dynamic> future = Future(() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString("loginToken");
  });
  future.then((val){
      return val;
  }).catchError((_){
      print("catchError");
  });
    
}