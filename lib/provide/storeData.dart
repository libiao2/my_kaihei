import 'package:flutter/material.dart';

class StoreData with ChangeNotifier{
  int bottom_sheet_choose = 0;
  Map userInfo = null;
  bool roomIsOpen = false; // 房间是否处于匹配状态，初始都为关
  List room_user_list = null; // 房间人数列表
  List show_room_user = null; // 房间人数展示，没有房主
  Map room_info = null; /// 房间信息
  List chatList = []; /// 房间聊天内容
  bool isOut = false; /// 自己是否被踢出房间
  int homeRoomNo = null; /// 通过首页进入房间
  Map joinRoomIsOk = null; /// 加入房间是否成功
  bool isJumpBottom = false; /// 房间内消息列表更新，需要跳到底部
  var roomImg = null; // 房间头像
  bool isCanSpeak = true; /// 进入房间是否可以说话
  bool isCanListen = true; /// 进入房间要不要听
  bool isCall = false; /// 聊天电话进来了
  bool isMatchErr = false; /// 匹配是否失败
  bool isRefresh = false;    /// 主要用于退出房间刷新首页用

  int typeIndex = null; //// 篩選頻道，列表要改變

  List homeCardList = null; /// 首页房间列表
  int homeGameId = 1;   ///当前选择的首页游戏类型
  Map addCardItem = null; //// 房间新增

  bool socketIsBroken = false;  /// socket是否断开连接，初始化为false，未断开


  changeSocket(data) {
    socketIsBroken = data;
    notifyListeners();
  }
  

  changeBottomSheetChoose(data) {
    bottom_sheet_choose = data;
    notifyListeners();
  }

  setUserInfo(data) {
    userInfo = data;
    notifyListeners();
  }

  setRoomUserList(data) {
    print('77777777777777777777777777777777$data');
    var copy = [];
    
    for(int i = 0; i < data.length; i += 1) {
      if(!data[i]['is_admin']) {
        copy.add(data[i]);
      } else {
        roomImg = data[i]['avatar'];
      }
    }

    room_user_list = data;
    show_room_user = copy;
    notifyListeners();
  }

  changeRoomUserList(data) {
    if(!data['is_admin']) {
      show_room_user.add(data);
    }
    room_user_list.add(data);
    notifyListeners();
  }

  setRoomInfo(data) {  // 获取房间信息
    room_info = data;
    notifyListeners();
  }

  saveChatList(data) { // 存储聊天内容
    chatList.add(data);
    notifyListeners();
  }
  deleteRoomchat() { // 删除聊天
    chatList = [];
    notifyListeners();
  }

  setRoomIsOpen(data) { // 设置房间匹配
  print('///////////////////////////////$data');
    roomIsOpen = data;
    notifyListeners();
  }

  setIsOut(data) { /// 自己是否被踢
    isOut = data;
    notifyListeners();
  }

  saveHomeRoomNo(data) { /// 退出房间，保留socket连接
    homeRoomNo = data;
    notifyListeners();
  }
  
  setjoinRoomIsOk(data) { // 加入房间是否成功回调
    joinRoomIsOk = data;
    notifyListeners();
  }

  setJumpBottom(data) {
    isJumpBottom = data;
    notifyListeners();
  }

  saveHomeRoomImg(data) {
    roomImg = data;
    notifyListeners();
  }

  changeIsCanSpeak(data) {
    isCanSpeak = data;
    notifyListeners();
  }

  changeIsCanListen(data) {
    isCanListen = data;
    notifyListeners();
  }

  changeCall(data) {
    isCall = data;
    notifyListeners();
  }

  matchingErrBack(data) {
    isMatchErr = data;
    notifyListeners();
  }

  changeRefresh(data) {
    isRefresh = data;
    notifyListeners();
  }

  changeTypeIndex(data) {
    typeIndex = data;
    notifyListeners();
  }

  saveHomeCardList(data) {   /// 保存首页房间列表
    homeCardList = data;
    notifyListeners();
  }

  changeHomeCardList(data) {   /// 添加新房间
    var newList = [];
    newList.add(data);
    newList.addAll(homeCardList);
    homeCardList = newList;
    notifyListeners();
  }

  saveHomeGameId(data){
    print('cccccccccccccccccccccccccccccccccccccccccc$data');
    homeGameId = data;
    notifyListeners();
  }

  addRoom(data) {
    print('FFFFFFFFFFFFFFFFFFFFFFFFFFFF$data');
    addCardItem = data;
    notifyListeners();
  }
}