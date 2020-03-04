import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../utils/Constants.dart';

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:premades_nn/components/ImageLayer.dart';
import 'package:premades_nn/type/MessageType.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/ImageUtil.dart';
import 'package:premades_nn/utils/PermissionHelper.dart';
import 'package:premades_nn/utils/SocketHelper.dart';

Widget sendImg(room_no, assetList, sendCallBack, context) {
  return Column(
    children: <Widget>[
      Container(
        height: Constants.keyBoardHeight - 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: assetList.length,
          itemBuilder: (BuildContext context, int index) {
            return photoItem(assetList[index]);
          },
        ),
      ),
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
              onTap: () {
                PermissionHelper.checkPermission(
                    context,
                    "需要存储权限查看手机相册图片，是否前往打开应用权限？",
                    PermissionGroup.storage, () async {
                  List<AssetEntity> resultList =
                      await PhotoPicker.pickAsset(
                          context: context,
                          pickType: PickType.onlyImage);
                  resultList.forEach((assetEntity) async {
                    File imageFile = await assetEntity.file;
                    ImageUtil.uploadImg(imageFile)
                        .then((response) {
                      if (response != null &&
                          response["code"] == 0) {
                        String url = response['data']['url'];
                        //发送图片 socket信息
                        SocketHelper.sendRoomMessage(room_no, 2, url, context);
                      }
                    });
                  });
                });
              },
              child: Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  "相册",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                if (Constants.selectedList != null &&
                    Constants.selectedList.length > 0) {
                  Constants.selectedList
                      .forEach((assetEntity) async {
                    File imageFile = await assetEntity.file;
                    ImageUtil.uploadImg(imageFile)
                        .then((response) {
                      if (response != null &&
                          response["code"] == 0) {
                        String url = response['data']['url'];
                        //发送图片 socket信息
                        SocketHelper.sendRoomMessage(room_no, 2, url, context);
                      }
                    });
                    Constants.selectedList.clear();
                  });
                  sendCallBack();
                } else {
                  Fluttertoast.showToast(
                      msg: "请选择图片！",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIos: 1,
                      backgroundColor: Colors.black54,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
              child: Container(
                margin: EdgeInsets.only(right: 10),
                padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                child: Text(
                  "发送",
                  style: TextStyle(color: Colors.white),
                ),
                decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.all(Radius.circular(20)),
                    gradient: LinearGradient(
                      colors: [ColorUtil.btnStartColor, ColorUtil.btnEndColor],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter
                    )),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget photoItem(AssetEntity assetEntity) {
    int height = Constants.keyBoardHeight.floor() - 50;
    int width = ((Constants.keyBoardHeight - 50) *
            assetEntity.width /
            assetEntity.height)
        .floor();

    if (width < 80) {
      width = 80;
    }
    return FutureBuilder<Uint8List>(
      future: assetEntity.thumbDataWithSize(height, width),
      builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
        var futureData = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done &&
            futureData != null) {
          return InkWell(
            onTap: (){
              print('mmmmmmmmmmmmmm');
            },
            child: Container(
              width: width.ceilToDouble(),
              height: (Constants.keyBoardHeight - 50),
              child: Stack(
                alignment: Alignment.topRight,
                children: <Widget>[
                  _buildImageItem(context, futureData, assetEntity),
                  ImageLayer(assetEntity: assetEntity),
                ],
              ),
            ),
          );
        }
        return Center(
          child: DefaultLoadingDelegate().buildPreviewLoading(
            context,
            assetEntity,
            Colors.grey,
          ),
        );
      },
    );
  }

  Widget _buildImageItem(
      BuildContext context, Uint8List data, AssetEntity assetEntity) {
    double width = (Constants.keyBoardHeight - 50) /
        assetEntity.height *
        assetEntity.width;

    if (width < 80.0) {
      width = 80.0;
    }

    var image = Image.memory(
      data,
      width: width,
      height: (Constants.keyBoardHeight - 50),
      fit: BoxFit.fitWidth,
    );
    var badge = Container();

    return Stack(
      children: <Widget>[
        image,
        IgnorePointer(
          child: badge,
        ),
      ],
    );
  }