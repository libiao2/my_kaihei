import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';
import '../service/service.dart';
import '../service/service_url.dart';
import '../page/matching/matching_screen.dart';
import '../provide/storeData.dart';

var choose = 0;
var nameList = [];

var area = [];
var areaIndex = 0;

var level = [];
var levelIndex = 0;

var model = [];
var modelIndex = 0;

Widget bottomSheet(context, title, data, callback) {
  // Provide.value<StoreData>(context).matchingErrBack(false);
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
                            left: 15.0,
                            right: 15.0
                            // bottom: 15.0,
                          ),
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
                                    width: 30.0,
                                    height: 30.0,
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
                                  _gameList(data, setDialogState),
                                  /// 大区
                                  _areaList(data, setDialogState),
                                  /// 段位
                                  _levelList(data, setDialogState),
                                  /// 模式
                                  _modelList(data, setDialogState),
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
                                var data = {
                                  'game_id': nameList[choose]['game_id'],
                                  'area_id': area[areaIndex]['area_id'],
                                  'level_id': level[levelIndex]['level_id'],
                                  'mode_id': model[modelIndex]['mode_id'],
                                };
                                switch (title) {
                                  case '筛选':
                                    Provide.value<StoreData>(context).changeTypeIndex(nameList[choose]['game_id']);
                                    Navigator.pop(context);
                                    callback(data);
                                    break;
                                  case '速配队友':
                                    Navigator.pop(context);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => MatchingScreen(
                                          data: data,
                                        ),
                                      ),
                                    );
                                    break;
                                  default:
                                }
                                
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