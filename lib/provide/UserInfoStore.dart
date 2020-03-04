import 'package:flutter/material.dart';
import 'package:premades_nn/model/user_info_entity.dart';

class UserInfoStore with ChangeNotifier{
  UserInfoEntity userInfo;

  setUserInfo(data) {
    userInfo = UserInfoEntity.fromJson(data);
  }

  updateUserInfo(){
    notifyListeners();
  }

}