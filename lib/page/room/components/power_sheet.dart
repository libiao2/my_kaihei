import 'package:flutter/material.dart';
import 'package:premades_nn/page/news/user_info.dart';
import 'package:premades_nn/provide/storeData.dart';
import 'package:provide/provide.dart';
import '../../../service/service_url.dart';
import '../../../service/service.dart';
import '../../../utils/SocketHelper.dart';
import '../../../components/toast.dart';

Widget powerSheet(context, nnId, roomNo) {
  bool isFriend = false;
  request('post', allUrl['userPublicInfo'], {'nn_id': nnId}).then((val) {
    if (val['code'] == 0) {
      if(val['data']['user']['friend_info'] != null) {   /// 是好友
          isFriend = true;
      }
    }
  });
  List setList;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext showModalContex) {
          return Provide<StoreData>(
            builder: (showModalContex, child, storeData){
              var myRole; // 自己的角色
              var otherRole; // 被点击人的角色
              var otherInfo; // 别人的信息
              storeData.room_user_list.forEach((res){
                if(res['nn_id'] == storeData.userInfo['nn_id']) {
                  myRole = res['is_admin'];
                }
                if(res['nn_id'] == nnId) {
                  otherRole = res['is_admin'];
                  otherInfo= res;
                }
              });

              if(myRole) {
                if(storeData.userInfo['nn_id'] != nnId) {
                  var isOut = true;  // 是否退出房间,初始化为退出
                  storeData.room_user_list.forEach((res){
                    if(res['nn_id'] == nnId) {
                      isOut = false;
                    }
                  });
                  if(!isOut) {
                    if(!isFriend) {
                      setList = [ '查看个人资料', '加为好友', '闭麦', '禁止打字', null, '踢出房间' ];
                      if(!otherInfo['isTypeWrite']) {
                        setList[3] = '允许打字';
                      } else {
                        setList[3] = '禁止打字';
                      }

                      if(!otherInfo['isClosedWheat']) {
                        setList[2] = '开麦';
                      } else {
                        setList[2] = '闭麦';
                      }
                    } else {
                      setList = [ '查看个人资料', '闭麦', '禁止打字', null, '踢出房间' ];
                      if(!otherInfo['isTypeWrite']) {
                        setList[2] = '允许打字';
                      } else {
                        setList[2] = '禁止打字';
                      }

                      if(!otherInfo['isClosedWheat']) {
                        setList[1] = '开麦';
                      } else {
                        setList[1] = '闭麦';
                      }
                    }
                      
                  
                      
                  } else {
                    if(isFriend) {
                      setList = [ '查看个人资料' ];
                    } else {
                      setList = [ '查看个人资料', '加为好友' ];
                    }
                    
                  }
                  
                } else {
                  setList = [ '查看个人资料' ];
                }
              } else {
                if(storeData.userInfo['nn_id'] != nnId) {
                  if(isFriend) {
                      setList = [ '查看个人资料' ];
                    } else {
                      setList = [ '查看个人资料', '加为好友' ];
                    }
                } else {
                  setList = [ '查看个人资料' ];
                }
                
              }

              var mHeight;
              switch (setList.length) {
                case 1:
                  mHeight = 50.0;
                  break;
                case 2:
                  mHeight = 100.0;
                  break;
                case 5:
                  mHeight = 206.0;
                  break;
                case 6:
                  mHeight = 256.0;
                  break;
                default:
              }
              return Container(
                height: mHeight,
                alignment: Alignment.center,
                child: Column(
                  children: setList.map((res){
                    return InkWell(
                      onTap: () {
                        Navigator.pop(showModalContex);
                        switch (res) {
                          case '查看个人资料':
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => UserInfo(
                                  nnid: nnId,
                                ),
                              ),
                            );
                            break;
                          case '加为好友':
                            request('post', allUrl['getUserInfo'], {'nn_id': nnId}).then((val) {
                              if (val['code'] == 0) {
                                if(val['data']['user']['friend_info'] == null) {
                                  toast('好友添加请求已发送！');
                                  SocketHelper.addFriend(nnId, 2, '', 1);
                                } else {
                                  toast('该用户已添加，请勿重复添加');
                                }
                              }
                            });
                            break;
                          case '闭麦':
                            SocketHelper.isClosedWheat(roomNo, nnId, false, context);
                            break;
                          case '开麦':
                            SocketHelper.isClosedWheat(roomNo, nnId, true, context);
                            break;
                          case '禁止打字':
                            SocketHelper.setTypewrite(roomNo, nnId, false, context);
                            break;
                          case '允许打字':
                            SocketHelper.setTypewrite(roomNo, nnId, true, context);
                            break;
                          case '踢出房间':
                            SocketHelper.kickedOutRoom(roomNo, nnId, true, context);
                            break;
                          default:
                        }
                      },
                      child: Container(
                        height: res == null ? 6.0 : 50.0,
                        alignment: Alignment.center,
                        child: Text(res == null ? '' : res, style: TextStyle(
                          color: res == '踢出房间' ? Colors.red : Colors.black
                        ),),
                        decoration: BoxDecoration(
                          color: res == null ? Color.fromRGBO(245, 245, 245, 1.0) : Colors.white,
                          border: Border(bottom: BorderSide(width: 1, color: Color.fromRGBO(240, 240, 240, 1.0))),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }
          );
      },
    ).then((val) {
      // 打印 点击返回的数据
      print(val);
    });
}