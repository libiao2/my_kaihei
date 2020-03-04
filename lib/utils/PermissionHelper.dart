import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper{

  ///获取存储权限
  static void checkPermission(BuildContext context, String tips, PermissionGroup permissionGroup, Function callback){
    PermissionHandler().checkPermissionStatus(permissionGroup).then((permission){
      if (permission == PermissionStatus.granted) {
        callback();
      } else {
        PermissionHandler().requestPermissions([permissionGroup]).then((permissions){
          permissions.forEach((key, value){
            if (key == permissionGroup && value == PermissionStatus.granted){
              callback();
            } else {
//              ChooseDialog.showTipDialog(context, tips,(){
//                PermissionHandler().openAppSettings();
//                Navigator.pop(context);
//              }, (){
//                Navigator.pop(context);
//              });
            }
          });
        });
      }
    });
  }

}