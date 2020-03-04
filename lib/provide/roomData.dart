import 'package:flutter/material.dart';

class RoomData with ChangeNotifier{
  Map isLastOne = null; /// 是不是最后一个退出房间，如果最后一个退出房间，那么返回首页需要把没删掉的房间删除

  bool isOnLine = false;  /// 是否正在语音通话


  changeIsLastOne(data) {
    print('0000000000000000000$data');
    isLastOne = data;
    notifyListeners();
  }

  changeIsOnLine(data) {
    isOnLine = data;
    notifyListeners();
  }
}