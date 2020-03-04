import 'dart:convert';
import 'dart:io';

import 'package:city_pickers/city_pickers.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/NetLoadingDialog.dart';
import 'package:premades_nn/provide/UserInfoStore.dart';
import 'package:premades_nn/provide/storeData.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/ImageUtil.dart';
import 'package:premades_nn/utils/PermissionHelper.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'package:provide/provide.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import 'edit_user_name.dart';
import 'edit_user_signature.dart';

class MyInformationScreen extends StatefulWidget {
  _MyInformationState createState() => _MyInformationState();
}

/*区分年月日选择器*/
enum NUM_TYPE {
  NUM_TYPE_YEAR,
  NUM_TYPE_MONTH,
  NUM_TYPE_DAY,
}

class _MyInformationState extends State<MyInformationScreen> {
  /*最下年份*/
  int _minYear = 1900;

  /*最大年份*/
  int _maxYear = 2019;

  /*当前选中年份*/
  int _seleYear = 2000;

  /*最小月份*/
  int _minMonth = 1;

  /*最大月份*/
  int _maxMonth = 12;

  /*当前选中月份*/
  int _seleMonth = 1;

  /*最小日*/
  int _minDay = 1;

  /*最大日*/
  int _maxDay = 30;

  /*当前选中日*/
  int _seleDay = 1;

  /*当前年份*/
  int _currentYear = 0;

  /*当前月份*/
  int _currentMonth = 0;

  /*当前日*/
  int _currentDay = 0;

  @override
  Widget build(BuildContext context) {
    Image headImg;
    if (Constants.headImgFile == null) {
      headImg = Image.network(
        Constants.userInfo.avatar,
      );
    } else {
      headImg = Image.file(
        Constants.headImgFile,
      );
    }

    String gender;
    if (Constants.userInfo.gender == 1) {
      gender = "男";
    } else if (Constants.userInfo.gender == 2) {
      gender = "女";
    } else {
      gender = "";
    }

    return Provide<UserInfoStore>(builder: (context, child, userInfoStore) {
      return Material(
        child: Column(
          children: <Widget>[
            AppBarWidget(isShowBack: true, centerText: Strings.myInfomation),
            SingleChildScrollView(
                child: Container(
              margin: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 10,
                    color: Color.fromRGBO(242, 242, 242, 1),
                  ),

                  ///头像
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(builder: (context1, state) {
                              // 这里的state就是setState
                              return Container(
                                height: 160,
                                color: Colors.white,
                                child: Column(
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () async {
                                        checkPermission(0);
                                      },
                                      child: Container(
                                        height: 50,
                                        alignment: Alignment(0.0, 0.0),
                                        child: Text("选择手机相册",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey)),
                                      ),
                                    ),
                                    Divider(
                                      height: 0.0,
                                      indent: 0.0,
                                      color: Colors.grey,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        checkPermission(1);
                                      },
                                      child: Container(
                                        height: 50,
                                        alignment: Alignment(0.0, 0.0),
                                        child: Text("拍照",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey)),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 5,
                                            color: Color.fromRGBO(
                                                242, 242, 242, 1.0)),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop(); //隐藏弹出框
                                      },
                                      child: Container(
                                        height: 50,
                                        alignment: Alignment(0.0, 0.0),
                                        child: Text("取消",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                          });
                    },
                    child: Container(
                      height: 80.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("头像",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          Row(
                            children: <Widget>[
                              Container(
                                  width: ScreenUtil().setWidth(60),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipOval(
                                      child: headImg,
                                    ),
                                  )),
                              Icon(
                                Icons.navigate_next,
                                color: Colors.grey,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Color.fromRGBO(242, 242, 242, 1),
                  ),

                  ///昵称
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return EditUserNameScreen();
                      }));
                    },
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("昵称",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          Row(
                            children: <Widget>[
                              Text(userInfoStore.userInfo.nickname,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                              Icon(
                                Icons.navigate_next,
                                color: Colors.grey,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Color.fromRGBO(242, 242, 242, 1),
                  ),

                  ///个性签名
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return EditUserSignatureScreen();
                      }));
                    },
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "个性签名",
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(userInfoStore.userInfo.intro,
                                      textAlign: TextAlign.right,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.grey)),
                                ),
                                Icon(
                                  Icons.navigate_next,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Color.fromRGBO(242, 242, 242, 1),
                  ),

                  ///NN号
                  InkWell(
                    onTap: () {},
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("NN号",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          Padding(
                            padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                            child: Text(userInfoStore.userInfo.nnId.toString(),
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Color.fromRGBO(242, 242, 242, 1),
                  ),

                  ///性别
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(builder: (context1, state) {
                              // 这里的state就是setState
                              return Container(
                                height: 160,
                                color: Colors.white,
                                child: Column(
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        updateUserGender(1);
                                      },
                                      child: Container(
                                        height: 50,
                                        alignment: Alignment(0.0, 0.0),
                                        child: Text("男",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey)),
                                      ),
                                    ),
                                    Divider(
                                      height: 0.0,
                                      indent: 0.0,
                                      color: Colors.grey,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        updateUserGender(2);
                                      },
                                      child: Container(
                                        height: 50,
                                        alignment: Alignment(0.0, 0.0),
                                        child: Text("女",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey)),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 5,
                                            color: Color.fromRGBO(
                                                242, 242, 242, 1.0)),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).pop(); //隐藏弹出框
                                      },
                                      child: Container(
                                        height: 50,
                                        alignment: Alignment(0.0, 0.0),
                                        child: Text("取消",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey)),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                          });
                    },
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("性别",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          Row(
                            children: <Widget>[
                              Container(
                                margin:
                                    EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                child: Text(gender,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey)),
                              ),
                              Icon(
                                Icons.navigate_next,
                                color: Colors.grey,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Color.fromRGBO(242, 242, 242, 1),
                  ),

                  ///地区
                  InkWell(
                    onTap: _onAddressClick,
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("地区",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          Row(
                            children: <Widget>[
                              Text(
                                  userInfoStore.userInfo.region1 +
                                      " " +
                                      userInfoStore.userInfo.region2,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                              Icon(
                                Icons.navigate_next,
                                color: Colors.grey,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Color.fromRGBO(242, 242, 242, 1),
                  ),

                  ///生日
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(builder: (context1, state) {
                              return Container(
                                height: 250,
                                color: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.only(top: 10),
                                            child: Text(
                                              "取消",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blue),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            submitBirthday();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.only(top: 10),
                                            child: Text(
                                              "确定",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.blue),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Center(
                                            child: Container(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: <Widget>[
                                                  NumberPicker.integer(
                                                      initialValue: _seleYear,
                                                      minValue: _minYear,
                                                      maxValue: _maxYear,
                                                      itemExtent: 40,
                                                        // lastStr: "年",
                                                      infiniteLoop: false,
                                                      onChanged: (n) {
                                                        _seleYear = n;
                                                        _numChanged(
                                                            n,
                                                            NUM_TYPE
                                                                .NUM_TYPE_YEAR,
                                                            state);
                                                      }),
                                                  NumberPicker.integer(
                                                      initialValue: _seleMonth,
                                                      minValue: _minMonth,
                                                      maxValue: _maxMonth,
                                                      itemExtent: 40,
                                                        // lastStr: "月",
                                                      onChanged: (n) {
                                                        _numChanged(
                                                            n,
                                                            NUM_TYPE
                                                                .NUM_TYPE_MONTH,
                                                            state);
                                                      }),
                                                  NumberPicker.integer(
                                                      initialValue: _seleDay,
                                                      minValue: _minDay,
                                                      maxValue: _maxDay,
                                                      itemExtent: 40,
                                                        // lastStr: "日",
                                                      onChanged: (n) {
                                                        _numChanged(
                                                            n,
                                                            NUM_TYPE
                                                                .NUM_TYPE_DAY,
                                                            state);
                                                      }),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                          });
                    },
                    child: Container(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("生日",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black)),
                          Row(
                            children: <Widget>[
                              Text(userInfoStore.userInfo.birthday,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey)),
                              Icon(
                                Icons.navigate_next,
                                color: Colors.grey,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: Color.fromRGBO(242, 242, 242, 1),
                  ),
                ],
              ),
            ))
          ],
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();

    _getCurrentDate();
  }

  ///修改性别
  void updateUserGender(int i) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return NetLoadingDialog(
            outsideDismiss: false,
            loadingText: "修改性别中...",
          );
        });

    var data = {
      'gender': i,
    };
    updateUserInfo(data, null);
  }

  void checkPermission(int type) {
    if (type == 0) {
      PermissionHelper.checkPermission(
          context, "需要存储权限查看手机相册图片，是否前往打开应用权限？", PermissionGroup.storage, () {
        uploadHeadImage(type);
      });
    } else {
      PermissionHelper.checkPermission(
          context, "需要拍照权限，是否前往打开应用权限？", PermissionGroup.camera, () {
        uploadHeadImage(type);
      });
    }
  }

  ///上传头像
  Future uploadHeadImage(int type) async {
    File image;
    if (type == 0) {
      image = await ImagePicker.pickImage(source: ImageSource.gallery);
    } else {
      image = await ImagePicker.pickImage(source: ImageSource.camera);
    }
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: image.path,
      maxWidth: 150,
      maxHeight: 150,
    );
    if (croppedFile != null) {
      image = croppedFile;
    } else {
      return;
    }

    NetLoadingDialog.showLoadingDialog(context, "头像上传中...");
    ImageUtil.uploadImg(image).then((res) {
      var resData = res['data'];
      String picUrl = resData['url'];
      if (res['code'] == 0) {
        var data = {
          'avatar': picUrl,
        };
        updateUserInfo(data, image);
      }
    }).catchError((e) {
      print(e.toString());
    });
  }

  ///修改地区
  Future _onAddressClick() async {
    Result result = await CityPickers.showCityPicker(
        context: context,
        height: 300,
        showType: ShowType.pc,
        itemExtent: 40,
        itemBuilder: (item, list, index) {
          return Center(
              child: Text(item, maxLines: 1, style: TextStyle(fontSize: 14)));
        });

    if (result != null) {
      NetLoadingDialog.showLoadingDialog(context, "修改地址中...");
      var data = {
        'region1': result.provinceName,
        'region2': result.cityName,
      };
      updateUserInfo(data, null);
    }
  }

  ///修改个人信息
  void updateUserInfo(Map data, File image) {
    request('post', allUrl['user_information'], data).then((val) async {
      Navigator.of(context).pop();
      if (val['code'] == 0) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        if (data["birthday"] != "" && data["birthday"] != null) {
          Constants.userInfo.birthday = data["birthday"];
          Provide.value<UserInfoStore>(context).userInfo.birthday =
              data["birthday"];
          Provide.value<UserInfoStore>(context).updateUserInfo();
          Navigator.of(context).pop();
        }
        if (data["nickname"] != "" && data["nickname"] != null) {
          Constants.userInfo.nickname = data["nickname"];
          Provide.value<UserInfoStore>(context).userInfo.nickname =
              data["nickname"];
          Provide.value<UserInfoStore>(context).updateUserInfo();
        }
        if (data["avatar"] != "" && data["avatar"] != null) {
          Constants.userInfo.avatar = data["avatar"];
          Provide.value<UserInfoStore>(context).userInfo.avatar =
              data["avatar"];
          Provide.value<UserInfoStore>(context).updateUserInfo();

          String picName = data["avatar"].substring(
              data["avatar"].lastIndexOf("/") + 1,
              data["avatar"].lastIndexOf("."));

          ImageUtil.fetchImage(Constants.userInfo.avatar, picName).then((val) {
            setState(() {
              Constants.headImgFile = image;
              Navigator.of(context).pop();
            });
          });
        }
        if (data["intro"] != "" && data["intro"] != null) {
          Constants.userInfo.intro = data["intro"];
          Provide.value<UserInfoStore>(context).userInfo.intro = data["intro"];
          Provide.value<UserInfoStore>(context).updateUserInfo();
        }
        if (data["region1"] != "" && data["region1"] != null) {
          Constants.userInfo.region1 = data["region1"];
          Provide.value<UserInfoStore>(context).userInfo.region1 =
              data["region1"];
          Provide.value<UserInfoStore>(context).updateUserInfo();
        }
        if (data["region2"] != "" && data["region2"] != null) {
          Constants.userInfo.region2 = data["region2"];
          Provide.value<UserInfoStore>(context).userInfo.region2 =
              data["region2"];
          Provide.value<UserInfoStore>(context).updateUserInfo();
        }
        if (data["gender"] != null && data["gender"] != 0) {
          Constants.userInfo.gender = data["gender"];
          Provide.value<UserInfoStore>(context).userInfo.gender =
              data["gender"];
          Provide.value<UserInfoStore>(context).updateUserInfo();
          Navigator.of(context).pop();
        }

        prefs.setString("userInfo", json.encode(Constants.userInfo.toJson()));

        setState(() {});
      }
    });
  }

  ///选择器变化时
  void _numChanged(
      int newNum, NUM_TYPE type, void Function(void Function()) state) {
    if (type == NUM_TYPE.NUM_TYPE_YEAR) {
      _seleYear = newNum;
      if (_seleYear == _currentYear) {
        //选到了今年
        _maxMonth = _currentMonth;
        if (_seleMonth >= _currentMonth) {
          //选中月份大于当前月份
          _seleMonth = _currentMonth;
          if (_seleDay > _currentDay) {
            //选中日大于当前日
            _seleDay = _currentDay;
            _maxDay = _currentDay;
          }
        }
      } else {
        //如果当前选择的不是当前年份
        _maxMonth = 12;
        //根据年点年份月份获取当前月天数
        _maxDay = getDaysNum(_seleYear, _seleMonth);
        if (_seleDay > _maxDay) {
          //如果当前选中日大于当前日
          _seleDay = _maxDay;
        }
      }
    } else if (type == NUM_TYPE.NUM_TYPE_MONTH) {
      //选择月份
      _seleMonth = newNum;
      if (_seleMonth == _currentMonth && _seleYear == _currentYear) {
        _maxDay = _currentDay;
      } else {
        _maxDay = getDaysNum(_seleYear, _seleMonth);
      }
      if (_seleDay > _maxDay) {
        //如果当前选中日大于当前日
        _seleDay = _maxDay;
      }
    } else if (type == NUM_TYPE.NUM_TYPE_DAY) {
      //选择日
      _seleDay = newNum;
    }
    state(() {});
  }

  ///获取当前时间
  void _getCurrentDate() {
    _currentYear = int.parse(formatDate(DateTime.now(), [yyyy]));
    _maxYear = _currentYear;
    _currentMonth = int.parse(formatDate(DateTime.now(), [mm]));
    _currentDay = int.parse(formatDate(DateTime.now(), [dd]));

    setState(() {
      _seleYear = _currentYear;
      _seleMonth = _currentMonth;
      _seleDay = _currentDay;

      _maxYear = _currentYear;
      _maxMonth = _currentMonth;
      _maxDay = _currentDay;
    });
  }

  ///根据年份月份获取当前月有多少天
  int getDaysNum(int y, int m) {
    if (m == 1 || m == 3 || m == 5 || m == 7 || m == 8 || m == 10 || m == 12) {
      return 31;
    } else if (m == 2) {
      if (((y % 4 == 0) && (y % 100 != 0)) || (y % 400 == 0)) {
        //闰年 2月29
        return 29;
      } else {
        //平年 2月28
        return 28;
      }
    } else {
      return 30;
    }
  }

  void submitBirthday() {
    NetLoadingDialog.showLoadingDialog(context, "修改生日中...");

    String month;
    String day;
    if (_seleMonth < 10) {
      month = "0${_seleMonth}";
    } else {
      month = "${_seleMonth}";
    }
    if (_seleDay < 10) {
      day = "0${_seleDay}";
    } else {
      day = "${_seleDay}";
    }

    String birthday = "${_seleYear}-${month}-${day}";
    var data = {"birthday": birthday};
    updateUserInfo(data, null);
  }
}
