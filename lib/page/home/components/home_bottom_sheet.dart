import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/provide/storeData.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:provide/provide.dart';
import '../../../service/service.dart';
import '../../../service/service_url.dart';
import '../../room/room_screen.dart';
import '../../../utils/SocketHelper.dart';
import '../../../components/toast.dart';
import '../../../provide/roomData.dart';


var choose = 0;
var nameList = [];

var area = [];
var areaIndex = 0;

var level = [];
var levelIndex = 0;

var model = [];
var modelIndex = 0;

final controller = TextEditingController();

var roomName = null;

var myRoomNo;

Widget createRoombottomSheet(context, title, data, gameName) {
  choose = 0;
  nameList = [];

  area = [];
  areaIndex = 0;

  level = [];
  levelIndex = 0;

  model = [];
  modelIndex = 0;

  roomName = gameName;

  _isJoinOk(isOk, msg) {
    if(isOk) {
      // 删除聊天内容
      Provide.value<StoreData>(context).deleteRoomchat();
      Provide.value<StoreData>(context).setIsOut(false); // 初始化房间自己没被踢
      Provide.value<StoreData>(context).saveHomeRoomNo(null); //删除保留的房号
      Provide.value<StoreData>(context).changeIsCanSpeak(true); //初始化进入房间，默认可以讲话
      Provide.value<StoreData>(context).changeIsCanListen(true); //初始化进入房间，默认可以听见其他人说话
      Provide.value<StoreData>(context).saveHomeRoomImg(null);
      Navigator.pop(context);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RoomScreen(
            room_no: myRoomNo,
            isOnLine: Provide.value<RoomData>(context).isOnLine,
          ),
        ),
      );
    } else {
      toast(msg);
    }
  }

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Scaffold(
            body: Stack(
            children: <Widget>[
              Container(
                height: 30.0,
                width: double.infinity,
                color: Colors.black54,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  )
                ),
              ),
              Container(
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 15.0,
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(
                                  left: 15.0,
                                  right: 15.0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(title, style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500)),
                                    InkWell(
                                      onTap: (){
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        width: 30.0,
                                        height: 30.0,
                                        child: Image.asset('images/cha.png'),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: ScreenUtil().setHeight(20.0),),
                              Expanded(
                                child: ListView(
                                  children: <Widget>[
                                    // 游戏名
                                    _gameList(data, setDialogState),
                                    /// 大区
                                    _areaList(data, setDialogState),
                                    /// 段位
                                    _levelList(data, setDialogState),
                                    /// 模式
                                    _modelList(data, setDialogState),
                                    /// 房间名
                                    _roomName(setDialogState)
                                  ],
                                )
                              ),
                            ],
                          ),
                        ),
                      ),
                      // button
                      Stack(
                        children: <Widget>[
                          Container(
                            width: ScreenUtil().setWidth(375.0),
                            height: ScreenUtil().setHeight(75.0),
                            padding: EdgeInsets.only(bottom: 15.0, top: 15.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'images/boli.png'),
                                fit: BoxFit.cover,
                              )
                            ),
                            // color: Color.fromRGBO(20, 255, 255, 0.1),
                            child: InkWell(
                                onTap: (){
                                  if(controller.text.length > 15) {
                                    toast('房间名请控制在15个字符以内~');
                                    return;
                                  }
                                  if(controller.text.length > 0) {
                                    if(controller.text != roomName) { /// 输入框和下边名字不一致，采用输入框的名字
                                      setDialogState(() {
                                        roomName = controller.text;
                                      });
                                    }
                                  }
                                  var data = {
                                    'name': roomName,
                                    'game_id': nameList[choose]['game_id'],
                                    'area_id': area[areaIndex]['area_id'],
                                    'level_id': level[levelIndex]['level_id'],
                                    'mode_id': model[modelIndex]['mode_id'],
                                  };
                                  if(roomName == null || roomName.length == 0) {
                                    toast('请输入房间名');
                                  }
                                  request('post', allUrl['createRoom'], data).then((val) {
                                    if (val['code'] == 0) {
                                      controller.clear(); //清空输入框
                                      setDialogState((){
                                        myRoomNo = val['data']['room_no'];
                                        SocketHelper.joinRoom(val['data']['room_no'], 0, context, _isJoinOk);
                                      });
                                      
                                    }
                                  });
                                  
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: ScreenUtil().setWidth(156.0),
                                  height: ScreenUtil().setHeight(44.0),
                                  child: Text('确认', style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.0,
                                  ),),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromRGBO(68, 68, 252, 1),
                                        Color.fromRGBO(142, 121, 254, 1),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(30)),
                                  ),
                                ),
                            ),
                          )
                        ] ,
                      ),
                    ],
                  ),
                )
            ],
          )
          );
        },
      );
    },
  ).then((val) {
      // 打印 点击返回的数据
      print(val);
    });

}

// 第一级 游戏名
Widget _gameList(data, setDialogState) {
  setDialogState((){
    nameList = [];
    for(int i = 0; i < data.length; i+=1) {
      nameList.add({
        'name': data[i]['game_name'],
        'game_id': data[i]['game_id'],
        'isCheck': false,
      });
    }
    nameList[choose]['isCheck'] = true;
  });
  
  return _shaiItem('游戏', nameList, setDialogState);
}

// 第二级 大区
Widget _areaList(data, setDialogState) {
  setDialogState(() {
    area = [];
    for(int i = 0; i < data[choose]['area'].length; i += 1) {
      area.add({
        'area_name': data[choose]['area'][i]['area_name'],
        'area_id': data[choose]['area'][i]['area_id'],
        'isCheck': false,
      });
    }
    area[areaIndex]['isCheck'] = true;
  });
  
  
  return _shaiItem('大区', area, setDialogState);
}

// 第三级 段位
Widget _levelList(data, setDialogState) {
  setDialogState(() {
    level = [];
    for(int i = 0; i < data[choose]['level'].length; i += 1) {
      level.add({
        'level_name': data[choose]['level'][i]['level_name'],
        'level_id': data[choose]['level'][i]['level_id'],
        'isCheck': false
      });
    }
    level[levelIndex]['isCheck'] = true;
  });
  
  return _shaiItem('段位', level, setDialogState);
}

/// 第四级 模式
Widget _modelList(data, setDialogState) {
  setDialogState((){
    model = [];
    for(int i = 0; i < data[choose]['mode'].length; i += 1) {
      model.add({
        'mode_name': data[choose]['mode'][i]['mode_name'],
        'mode_id': data[choose]['mode'][i]['mode_id'],
        'isCheck': false
      });
    }
    model[modelIndex]['isCheck'] = true;
  });
  return _shaiItem('模式', model, setDialogState);
}

Widget _shaiItem(name, list, setDialogState) {
    return Container(
      width: ScreenUtil().setWidth(375.0),
      padding: EdgeInsets.only(
        left: 15.0,
        right: 15.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(name, style: TextStyle(
            color: Colors.black,
            fontSize: 16.0
          )),
          SizedBox(height: ScreenUtil().setHeight(10.0),),
          Wrap(
            //水平间距
            spacing: ScreenUtil().setWidth(8.0),
            //垂直间距
            runSpacing: ScreenUtil().setHeight(8.0),
            //对齐方式
            alignment: WrapAlignment.start,
            children: _whichItem(name, list, setDialogState),
          ),
          SizedBox(height: ScreenUtil().setHeight(20.0),),
        ],
      ),
    );
  }

  _whichItem(name, list, setDialogState) {
    switch (name) {
      case '游戏':
        return _nameList(list, setDialogState);
      case '大区':
        return _areaNameList(setDialogState);
      case '段位':
        return _levelNameList(setDialogState);
      case '模式':
        return _modelNameList(setDialogState);
      default:
    }
  }

  List<Widget> _nameList(list, setDialogState) {
    List<Widget> nameList = [];
    for(int i = 0; i < list.length; i += 1) {
      nameList.add(
        InkWell(
          onTap: (){
            list[i]['isCheck'] = true;
            setDialogState((){
              choose = i;
              areaIndex = 0;
              levelIndex = 0;
              modelIndex = 0;
            });
            print('888899900087777777777$i');
          },
          child: Container(
            width: ScreenUtil().setWidth(78.0),
            height: ScreenUtil().setHeight(45.0),
            alignment: Alignment.center,
            decoration: list[i]['isCheck'] ?
              BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(68, 68, 252, 1),
                    Color.fromRGBO(142, 121, 254, 1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
                ),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              )
            :
              BoxDecoration(
                color: Color.fromRGBO(245, 245, 245, 1.0),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              )
            ,
            child: Text(list[i]['name'], style: TextStyle(
              color: list[i]['isCheck'] ? Colors.white : Colors.black
            )),
          ),
        )
      );
    }
    return nameList;
  }

  List<Widget> _areaNameList(setDialogState) {
    List<Widget> nameList = [];
    for(int i = 0; i < area.length; i += 1) {
      nameList.add(
        InkWell(
          onTap: (){
            setDialogState(() {
              areaIndex = i;
            });     
          },
          child: Container(
            width: ScreenUtil().setWidth(78.0),
            height: ScreenUtil().setHeight(45.0),
            alignment: Alignment.center,
            decoration: area[i]['isCheck'] ?
              BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(68, 68, 252, 1),
                    Color.fromRGBO(142, 121, 254, 1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
                ),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              )
            :
              BoxDecoration(
                color: Color.fromRGBO(245, 245, 245, 1.0),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              )
            ,
            child: Text(area[i]['area_name'], style: TextStyle(
              color: area[i]['isCheck'] ? Colors.white : Colors.black
            ),),
          ),
        )
      );
    };
    return nameList;
  }

  List<Widget> _levelNameList(setDialogState) {
    List<Widget> nameList = [];
    for(int i = 0; i < level.length; i += 1) {
      nameList.add(
        InkWell(
          onTap: (){
            setDialogState(() {
              levelIndex = i;
            }); 
          },
          child: Container(
            width: ScreenUtil().setWidth(78.0),
            height: ScreenUtil().setHeight(45.0),
            alignment: Alignment.center,
            decoration: level[i]['isCheck'] ?
              BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(68, 68, 252, 1),
                    Color.fromRGBO(142, 121, 254, 1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
                ),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              )
            :
              BoxDecoration(
                color: Color.fromRGBO(245, 245, 245, 1.0),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              )
            ,
            child: Text(level[i]['level_name'], style: TextStyle(
              color:  level[i]['isCheck'] ? Colors.white : Colors.black
            )),
          ),
        )
      );
    };
    return nameList;
  }

  List<Widget> _modelNameList(setDialogState) {
    List<Widget> nameList = [];
    for(int i = 0; i < model.length; i += 1) {
      nameList.add(
        InkWell(
          onTap: (){
            setDialogState(() {
              modelIndex = i;
            }); 
          },
          child: Container(
            width: ScreenUtil().setWidth(78.0),
            height: ScreenUtil().setHeight(45.0),
            alignment: Alignment.center,
            decoration: model[i]['isCheck'] ?
              BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(68, 68, 252, 1),
                    Color.fromRGBO(142, 121, 254, 1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
                ),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              )
            :
              BoxDecoration(
                color: Color.fromRGBO(245, 245, 245, 1.0),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
              )
            ,
            child: Text(model[i]['mode_name'], style: TextStyle(
              color:  model[i]['isCheck'] ? Colors.white : Colors.black
            )),
          ),
        )
      );
    };
    return nameList;
  }

  Widget _roomName(setDialogState) {
    
    return Container(
      width: ScreenUtil().setWidth(375.0),
      margin: EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              left: 15.0,
              right: 15.0,
            ),
            child: Text('房间名:', style: TextStyle(
              color: Colors.black,
              fontSize: 16.0
            )),
          ),
          SizedBox(height: ScreenUtil().setHeight(10.0),),
          Container(
            color: Color.fromRGBO(245, 245, 245, 1.0),
            padding: EdgeInsets.only(
                      left: 15.0,
                      right: 15.0,
                    ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    
                    alignment: Alignment.center,
                    height: ScreenUtil().setHeight(50.0),
                    child: TextField(
                          controller: controller,
                          cursorColor: ColorUtil.black,
                          decoration: InputDecoration.collapsed(hintText: '请输入房间名', hintStyle: TextStyle(color: Colors.black38, fontSize: 13)),
                          maxLines: 1,
                          autocorrect: true,
                          autofocus: false,
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Colors.black),
                          onChanged: (text) {
                          },
                          onSubmitted:(e){
                            setDialogState(() {
                              roomName = e;
                            });
                          },
                          enabled: true, //是否禁用
                        ),
                  )
                ),
                InkWell(
                  onTap: (){
                    controller.clear(); //清空输入框
                    request('post', allUrl['getRoomName'], null).then((val) {
                      if (val['code'] == 0) {
                        setDialogState(() {
                          roomName = val['data']['room_name'];
                        });
                      }
                    });
                  },
                  child: Container(
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.autorenew, size: 16.0, color: Color.fromRGBO(99, 66, 251, 1.0),),
                        Text('换一个', style: TextStyle(
                          fontSize: 14.0,
                          color: Color.fromRGBO(99, 66, 251, 1.0)
                        ))
                      ],
                    ),
                  )
                )
              ],
            ),
          ),
          SizedBox(height: 10.0,),
          Container(
            margin: EdgeInsets.only(
              left: 15.0
            ),
            child: Text(roomName, style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),)
          )
        ],
      ),
    );

  }