import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../service/service.dart';
import '../../../service/service_url.dart';
import '../../../components/CustomDialog.dart';
import '../../../components/toast.dart';

var choose = 0;
var nameList = [];

var area = [];
var areaIndex = 0;

var level = [];
var levelIndex = 0;

var adept = [];
var adeptIndex = [0];

Widget myBottomSheet(context, title, data, isChooseData, callback) {
  if(isChooseData != null) { // 修改卡片
    var isCheckId = isChooseData['game_id'];
    for(int i = 0; i < data.length; i+=1) {
      if(isCheckId == data[i]['game_id']) {
          choose = i;
        }
    }

    var newCheck = isChooseData['area_id'];
    for(int i = 0; i < data[choose]['area'].length; i += 1) {
      if(data[choose]['area'][i]['area_id'] == newCheck) {
        areaIndex = i;
      }
    }

    var levelCheck = isChooseData['level_id'];
    for(int i = 0; i < data[choose]['level'].length; i += 1) {
      if(data[choose]['level'][i]['level_id'] == levelCheck) {
        levelIndex = i;
      }
    }

    var adeptL = [];
    for(int a = 0; a < isChooseData['adept'].length; a += 1) {
      adeptL.add(isChooseData['adept'][a]['adept_id']);
    }
    adeptIndex = []; // 重置选中数组
    for(int i = 0; i < data[choose]['adept'].length; i += 1) {
      for(int b = 0; b < adeptL.length; b += 1) {
        if(data[choose]['adept'][i]['adept_id'] == adeptL[b]) {
          adeptIndex.add(i);
        }
      }
    }
  } else {
    choose = 0;
    nameList = [];

    area = [];
    areaIndex = 0;

    level = [];
    levelIndex = 0;

    adept = [];
    adeptIndex = [0];
  }
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Stack(
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
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  )
                ),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        // padding: EdgeInsets.all(15.0),
                        padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0),
                        child: Column(
                          children: <Widget>[
                            Row(
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
                                    width: 20.0,
                                    height: 20.0,
                                    child: Image.asset('images/cha.png'),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: ScreenUtil().setHeight(20.0),),
                            Expanded(
                              child: ListView(
                                children: <Widget>[
                                  // 游戏名
                                  _gameList(data, isChooseData, setDialogState),
                                  /// 大区
                                  _areaList(data, isChooseData, setDialogState),
                                  /// 段位
                                  _levelList(data, isChooseData, setDialogState),
                                  /// 擅长
                                  _adeptList(data, isChooseData, setDialogState),
                                ],
                              )
                            )
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
                          child: InkWell(
                              onTap: (){
                                if(adeptIndex.length == 0) {
                                  toast('请选择擅长选项！');
                                  return;
                                }
                                var ids = [];
                                for(int i = 0; i < adeptIndex.length; i += 1) {
                                  ids.add(adept[adeptIndex[i]]['adept_id']);
                                }
                                var data = {
                                  'game_id': nameList[choose]['game_id'],
                                  'area_id': area[areaIndex]['area_id'],
                                  'level_id': level[levelIndex]['level_id'],
                                  'adept_id': ids,
                                };

                                var myUrl = null;
                                if(isChooseData != null) {
                                  data['card_id'] = isChooseData['card_id'];
                                  myUrl = allUrl['editCard'];
                                } else {
                                  myUrl = allUrl['addCard'];
                                }

                                request('post', myUrl, data).then((val) {
                                  if (val['code'] == 0) {
                                    if(isChooseData != null) {
                                      toast('卡片修改成功！');
                                    } else {
                                      toast('卡片添加成功！');
                                    }
                                    callback();
                                    Navigator.pop(context);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: val["msg"],
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIos: 1,
                                        backgroundColor: Colors.black54,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
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
          );
        },
      );
    },
  ).then((val) {
      // 打印 点击返回的数据
      print('gggggggggggggggggggggggggggggggggg'+val);
    });

}

// 第一级 游戏名
Widget _gameList(data, isChooseData, setDialogState) {
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
Widget _areaList(data, isChooseData, setDialogState) {
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
Widget _levelList(data, isChooseData, setDialogState) {
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

/// 第四级 擅长
Widget _adeptList(data, isChooseData, setDialogState) {
  setDialogState((){
    adept = [];
    for(int i = 0; i < data[choose]['adept'].length; i += 1) {
      adept.add({
        'adept_name': data[choose]['adept'][i]['adept_name'],
        'adept_id': data[choose]['adept'][i]['adept_id'],
        'isCheck': false
      });
    }

    adeptIndex.forEach((item){
      adept[item]['isCheck'] = true;
    });
  });
  
  return _shaiItem('擅长(最多显示三个)', adept, setDialogState);
}

Widget _shaiItem(name, list, setDialogState) {
    return Container(
      width: ScreenUtil().setWidth(375.0),
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
      case '擅长(最多显示三个)':
        return _adeptNameList(setDialogState);
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
              adeptIndex = [0];
            });
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
              print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
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

  List<Widget> _adeptNameList(setDialogState) {
    List<Widget> nameList = [];
    for(int i = 0; i < adept.length; i += 1) {
      nameList.add(
        InkWell(
          onTap: (){
            setDialogState(() {
              if(adept[i]['isCheck']) {
                adeptIndex = (adeptIndex.where((item) => item != i)).toList();
              }
              if(adeptIndex.length < 3 && !adept[i]['isCheck']) {
                adeptIndex.add(i);
              }
            }); 
          },
          child: Container(
            width: ScreenUtil().setWidth(78.0),
            height: ScreenUtil().setHeight(45.0),
            alignment: Alignment.center,
            decoration: adept[i]['isCheck'] ?
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
            child: Text(adept[i]['adept_name'], style: TextStyle(
              color:  adept[i]['isCheck'] ? Colors.white : Colors.black
            )),
          ),
        )
      );
    };
    return nameList;
  }