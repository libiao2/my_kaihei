import 'dart:io';
import 'dart:ui';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/components/extended_text_field.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/PermissionHelper.dart';
import 'package:premades_nn/utils/SocketHelper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:provide/provide.dart';
import '../../provide/storeData.dart';
import './components/room_header.dart';
import './components/room_Owner.dart';
import '../../components/toast.dart';
import './components/room_member.dart';
import './components/messageItem.dart';
import './components/share_sheet.dart';
import './components/send_emoji.dart';
import './components/send_img.dart';
import '../../provide/roomData.dart';
import '../../event/room_have_news.dart';
import '../../components/my_special_text_span_builder.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../event/room_has_phone.dart';
import '../../event/room_no_phone.dart';
import '../../event/socket_is_broken.dart';


class RoomScreen extends StatefulWidget{
  final int room_no;
  final int newsLength;
  final bool isOnLine;
  RoomScreen({ this.room_no, this.newsLength, this.isOnLine });
  _RoomScreenState createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  ScrollController _scrollController;
  final controller = TextEditingController();
  final roomNamecontroller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  num showCount = 1;
  bool isClear = true;
  FocusNode changeNameNode = FocusNode();
  FocusScopeNode _focusScopeNode = FocusScopeNode();

  int isClick = null;  // 点击发送表情图片
  bool isChangeName = false; /// 是否更改房间名称

  List<AssetPathEntity> pathList = List();
  List<AssetEntity> assetList = List();

  bool haveLine = false;   /// 是否有语音电话进来

  void _jumpBottom(){//滚动到底部
    if(_scrollController.hasClients) {
      _scrollController.animateTo(9999,curve: Curves.easeOut, duration: Duration(milliseconds: 200));
    }
  }

  // 发送消息
  void _handleSubmitted(int type) {
      if(controller.text.length > 0) {
        SocketHelper.sendRoomMessage(widget.room_no, type, controller.text.toString(), context);
      }
      print(controller.text);
      controller.clear(); //清空输入框
  }

  void _roomNameSubmitted() {
    if(roomNamecontroller.text.length > 0) {
      if(roomNamecontroller.text.length <= 15) {
        SocketHelper.changeRoomName(widget.room_no, roomNamecontroller.text.toString(), context);
        setState(() {
          isChangeName = false;
        });
        roomNamecontroller.clear(); //清空输入框
        changeNameNode.unfocus(); /// 关闭软键盘
      } else {
        toast('房间名请控制在15个字符以内~');
      }
    }
  }

  void goHome() {
    setState(() {
      isClear = false;
      Provide.value<StoreData>(context).room_user_list.forEach((res){
        if(res['is_admin']) {
          Provide.value<StoreData>(context).saveHomeRoomImg(res['avatar']);
        }
      });
      Navigator.pop(context);
      Provide.value<StoreData>(context).saveHomeRoomNo(widget.room_no);
    });
  }

  // 聊天发送图片 表情回调，关闭高度
  void sendImgCallBack() {
    setState(() {
      isClick = null;
    });
  }

  void changeName() { /// 更改房间名称
    setState(() {
      roomNamecontroller.text = Provide.value<StoreData>(context).room_info['room_name'];
      isChangeName = true;
      showCount = 1;
    });
    // if(_focusScopeNode == null) _focusScopeNode = FocusScope.of(context);
    FocusScope.of(context).requestFocus(changeNameNode);
  }

  void getPhotos() async{
    pathList = await PhotoManager.getImageAsset();
    assetList = await pathList[0].assetList;
    setState(() {
      isClick = 2;
    });

    PermissionHelper.checkPermission(
        context, "需要存储权限，是否前往打开应用权限？", PermissionGroup.storage, () async {
          print('aa');
    });
  }

  void emojiCallBack(data) {
    setState(() {
      controller.text = controller.text + data;
    });
  }

  void speakChange(data) {
    if(data) {
      AgoraRtcEngine.muteLocalAudioStream(false); /// false 取消静音
    } else {
      AgoraRtcEngine.muteLocalAudioStream(true);
    }
  }

  /// Create agora sdk instance and initialze
  void _initAgoraRtcEngine(isCanSpeak) {
      AgoraRtcEngine.create(Constants.APP_ID);
      AgoraRtcEngine.enableAudio(); /// 启用音频模块

      /// 加入房间
      AgoraRtcEngine.joinChannel(null, widget.room_no.toString(), null, Constants.userInfo.nnId);
      print('hhhhhhhhhhhhkkkkkkkkkkkkkkkkkk');
      if(!isCanSpeak) { /// 房间内语音通话结束
        print('???????????????????????????????????????????');
        if(!Provide.value<StoreData>(context).isCanSpeak) {
          AgoraRtcEngine.muteLocalAudioStream(true);
          AgoraRtcEngine.enableLocalAudio(false);
        } else {
          AgoraRtcEngine.muteLocalAudioStream(false);
          AgoraRtcEngine.enableLocalAudio(true);
        }
        if(Provide.value<StoreData>(context).isCanListen) {
          AgoraRtcEngine.muteAllRemoteAudioStreams(false);
        } else {
          AgoraRtcEngine.muteAllRemoteAudioStreams(true);
        }
      }

      _addAgoraEventHandlers();
  }


   /// Add agora event handlers
   void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (code) {
      // sdk error
    };
    
    AgoraRtcEngine.onJoinChannelSuccess =
        (String channel, int uid, int elapsed) {
      // join channel success
      if(Platform.isIOS) {
        AgoraRtcEngine.setEnableSpeakerphone(true);
      }
       
      print('加入成功！！！！！！！！！！！！！！！');
    };
    
    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      // there's a new user joining this channel
      print('别人加入房间！！！！！！！！！！！！！');
    };
    
    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      // there's an existing user leaving this channel
      print('离开房间！！！！！！！！！！！！！');
    };
  }

  void initialize(bool isCanSpeak) {
    _initAgoraRtcEngine(isCanSpeak);
  }

  @override
  void initState() {
    super.initState();
    
    if(!widget.isOnLine) { /// 进入房间之前有语音聊天
      initialize(true);
    } else {
      print('xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
    }
    _scrollController = ScrollController();

    Timer(Duration(milliseconds: 1000), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));

    Constants.eventBus.on<RoomHasPhone>().listen((event) {
      if(event.isHave) {
        setState(() {
          haveLine = event.isHave;
        });
        print('556666667777778888889999999');
        AgoraRtcEngine.leaveChannel();
        AgoraRtcEngine.create(Constants.APP_ID);
        AgoraRtcEngine.enableAudio(); /// 启用音频模块

        /// 加入房间
        AgoraRtcEngine.joinChannel(null, '10000', null, Constants.userInfo.nnId);
      }
    });
    // 房间内挂断电话
    Constants.eventBus.on<RoomNoPhone>().listen((event) {
      if(event.isClose) {
        setState(() {
          haveLine = false;
        });

        AgoraRtcEngine.leaveChannel();
        initialize(false);
      }
    });

    /// 掉线重连通知
    Constants.eventBus.on<SocketIsBroken>().listen((event) {
      if(event.isConnect) {
        print('重连成功！！！！！！！！！！！！！！！！！！！！！！！！！！！！');
        SocketHelper.socketConnectAgain(context);
      }
    });
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // TextField has lost focus
        setState(() {
          isClick = null;
        });
      }
    });
    
  }

  @override
  void dispose() {
    super.dispose();
    Constants.roomContext = context;
    if(isClear) {  /// 关闭房间，不是缩小房间
      SocketHelper.goOutRoom(widget.room_no, context);
      AgoraRtcEngine.leaveChannel();
    }
    
  }

  @override
  Widget build(BuildContext context) {
    Constants.roomContext = context;
    EdgeInsets padding = MediaQuery.of(context).padding;
    double top = math.max(padding.top, EdgeInsets.zero.top); //计算状态栏的高度
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/room_bg.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  if(isChangeName) {
                    setState(() {
                      isChangeName = false;
                    });
                    // roomNamecontroller.clear(); //清空输入框
                    changeNameNode.unfocus(); /// 关闭软键盘
                  }
                  if(showCount == 4) {
                    setState(() {
                      showCount = 1;
                    });
                    _focusNode.unfocus();
                  }
                },
                child: Container(
                  padding: EdgeInsets.only(
                    top: top
                  ),
                  child: Column(
                    children: <Widget>[
                      // 头部
                      RoomHeader(
                        roomContext: context,
                        changeNameBack: changeName,
                        headerCallBack: goHome),
                      // 房主
                      RoomOwner(room_no: widget.room_no),
                      // 成员
                      RoomMembers(room_no: widget.room_no, speakCallback: speakChange),
                      // 聊天内容
                      Expanded(child: Chat()),
                      // 底部
                      _bottomSheet()
                    ],
                  ),
                ),
              ),
              // 修改房间名称
              _changeRoomName()
            ],
          )
        )
      ),
    );
  }

  Widget _changeRoomName() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Offstage(
        offstage: !isChangeName,
        child: Container(
          width: ScreenUtil().setWidth(375.0),
          padding: EdgeInsets.all(15.0),
          color: Color.fromRGBO(245, 245, 245, 1.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10.0),
                  margin: EdgeInsets.only(right: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0)
                  ),
                  child: Theme(
                    data: ThemeData(primaryColor: Colors.transparent, hintColor: Colors.transparent),
                    child: TextField(
                      controller: roomNamecontroller,
                      cursorColor: ColorUtil.black,
                      autofocus: isChangeName,
                      focusNode: changeNameNode,
                      decoration: InputDecoration(
                                hintText: '编辑房间名称',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                                disabledBorder: InputBorder.none,
                                enabledBorder:  InputBorder.none,
                                hintStyle: TextStyle(color: Colors.black38, fontSize: 13)),
                      onSubmitted:(val){
                        _roomNameSubmitted();
                      },
                    ),
                  )
                ),
              ),
              InkWell(
                onTap: (){
                  _roomNameSubmitted();
                },
                child: Container(
                  width: 60.0,
                  height: 32.0,
                  alignment: Alignment.center,
                  child: Text('确认', style: TextStyle(fontSize: 14.0, color: Colors.white)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(68, 68, 252, 1),
                        Color.fromRGBO(142, 121, 254, 1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                )
              )
            ],
          ),
        )
      )
    );
  }


  Widget Chat() {
    return Provide<StoreData>(
      builder: (context, child, data){
        if(data.chatList.length == 0) {
          return Container();
        }
        if(data.isOut) {
          // toast('您已经被房主请出房间！');
          Navigator.pop(context);
        }
        if(data.isJumpBottom) {
          _jumpBottom();
          Provide.value<StoreData>(context).setJumpBottom(false);
        }
        
        return Container(
          alignment: Alignment.topLeft,
          width: ScreenUtil().setWidth(375.0),
          padding: EdgeInsets.only(
            top: ScreenUtil().setHeight(10.0),
            bottom: ScreenUtil().setHeight(20.0),
          ),
          margin: EdgeInsets.only(
            left: ScreenUtil().setWidth(25.0), right: ScreenUtil().setWidth(25.0)
          ),
          child: ListView.builder(
            controller: _scrollController,
            physics: ClampingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return messageItem(data.chatList[index], widget.room_no, context, _jumpBottom);
            },
            itemCount: data.chatList.length,
          )
        );
      }
    );
  }

  Widget _bottomSheet() {
    switch (showCount) {
      case 1:
        return _one();
      case 4:
        return _four();
      default:
    }
  }

  Widget _one() {
    return Provide<StoreData>(
      builder: (context, child, storeData){
        var myInfo;
        storeData.room_user_list.forEach((res){
          print('333333333333333333333${res}');
          if(res['nn_id'] == storeData.userInfo['nn_id']) {
            myInfo = res;
            // Provide.value<StoreData>(context).changeIsCanSpeak(res['isClosedWheat']);
          }
        });
        return Container(
          height: ScreenUtil().setHeight(60.0),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Container(
                  child: InkWell(
                    onTap: (){
                      Provide.value<StoreData>(context).changeIsCanListen(!storeData.isCanListen);
                      if(storeData.isCanListen) {
                        AgoraRtcEngine.muteAllRemoteAudioStreams(false);
                      } else {
                        AgoraRtcEngine.muteAllRemoteAudioStreams(true);
                      }
                    },
                    child: Container(
                      width: 25.0,
                      height: 25.0,
                      child: Image.asset(storeData.isCanListen ? 'images/room_listen.png' : 'images/room_no_listen.png'),
                    ),
                  ),
                )
              ),
              Expanded(
                child: Container(
                  child: InkWell(
                    onTap: (){
                      if(myInfo['isClosedWheat']) {
                        Provide.value<StoreData>(context).changeIsCanSpeak(!storeData.isCanSpeak);
                        if(!haveLine) { /// 如果没有人来电话了
                          if(storeData.isCanSpeak) {
                            AgoraRtcEngine.muteLocalAudioStream(false);
                            AgoraRtcEngine.enableLocalAudio(true);
                          } else {
                            AgoraRtcEngine.muteLocalAudioStream(true);
                            AgoraRtcEngine.enableLocalAudio(false);
                          }
                        }
                      } else {
                        toast('您已被房主禁麦！');
                      }
                    },
                      child: Container(
                        width: 25.0,
                        height: 25.0,
                        child: Image.asset(storeData.isCanSpeak ? 'images/room_speak.png' : 'images/room_no_speak.png'),
                      ),
                  ),
                )
              ),
              Expanded(
                child: Container(
                  child: InkWell(
                    onTap: (){
                      shareSheet(context, roomNo: widget.room_no);
                    },
                    child: Container(
                      width: 25.0,
                      height: 25.0,
                      child: Image.asset('images/room_share.png'),
                    ),
                  ),
                )
              ),
              Expanded(
                child: Container(
                  child: InkWell(
                    onTap: (){
                      if(myInfo['isTypeWrite']) {
                        setState(() {
                          showCount = 4;
                        });
                        FocusScope.of(context).requestFocus(_focusNode);
                      } else {
                        toast('您目前被禁止打字!');
                      }
                    },
                    child: Container(
                      width: 25.0,
                      height: 25.0,
                      child: Image.asset('images/room_write.png'),
                    ),
                  ),
                )
              ),
            ],
          ),
        );
      }
    );
  }


  Widget _four() {
    return Provide<StoreData>(
      builder: (context, child, storeData){
        var myInfo;
        Widget _myWidget = null;
        storeData.room_user_list.forEach((res){
          print('4444444444444444444444${res['nn_id']}');
          if(res['nn_id'] == storeData.userInfo['nn_id']) {
            myInfo = res;
          }
        });

        switch (isClick) {
          case 1:
            _myWidget = sendEmoji(emojiCallBack);
            break;
          case 2:
            _myWidget = sendImg(widget.room_no, assetList, sendImgCallBack, context);
            break;
          default:
            _myWidget = noClick();
        }

        return InkWell(
          // onVerticalDragEnd: (details){
          //   setState(() {
          //     showCount = 1;
          //   });
          // },
          onTap: (){
            print('c');
          },
          child: Container(
            height: isClick != null ? 104.0 + Constants.keyBoardHeight : 104.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 15.0),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(left: 15.0, right: 15.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(25.0))
                          ),
                          child: Theme(
                            data: ThemeData(primaryColor: Colors.transparent, hintColor: Colors.blue),
                            child: ExtendedTextField(
                              controller: controller,
                              focusNode: _focusNode,
                              specialTextSpanBuilder: MySpecialTextSpanBuilder(),
                              enabled: myInfo['isTypeWrite'], // 是否禁用输入框
                              decoration: InputDecoration(
                                hintText: '发表评论',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                                disabledBorder: InputBorder.none,
                                enabledBorder:  InputBorder.none,
                                hintStyle: TextStyle(color: Colors.black38, fontSize: 13)),
                              maxLines: 1,
                              autocorrect: true,
                              autofocus: false,
                              textAlign: TextAlign.start,
                              style: TextStyle(color: Colors.black),
                              cursorColor: Colors.green,
                              onChanged: (text) {
                                setState(() {
                                    // hasText = text.length > 0 ?  true : false; 
                                });
                              },
                              onSubmitted:(val){
                                _handleSubmitted(1);
                              },
                            ),
                          )
                        )
                      ),
                      SizedBox(width: 15.0),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                    left: 18.0,
                    right: 18.0,
                    top: 8.0
                  ),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          InkWell(
                            onTap: (){
                              setState(() {
                                isClick = 1;
                              });
                              FocusScope.of(context).requestFocus(new FocusNode());
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                // top: 5.0,
                                // bottom: 5.0,
                                right: 5.0
                              ),
                              width: 30.0,
                              height: 30.0,
                              child: Image.asset('images/icon_emoji_on.png', fit: BoxFit.cover,)
                            ),
                          ),
                          SizedBox(width: 20.0),
                          InkWell(
                            onTap: (){
                              getPhotos();
                              FocusScope.of(context).requestFocus(new FocusNode()); /// 关闭键盘
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                // top: 5.0,
                                // bottom: 5.0,
                                right: 5.0
                              ),
                              width: 30.0,
                              height: 30.0,
                              child: Image.asset('images/icon_pic_on.png', fit: BoxFit.cover,)
                            ),
                          )
                        ],
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: (){
                              _handleSubmitted(1);
                              _focusNode.unfocus();
                              setState(() {
                                isClick = null;
                              });
                            },
                            child: Container(
                              width: 80.0,
                              height: 40.0,
                              alignment: Alignment.center,
                              child: Text('发送'),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromRGBO(254, 254, 254, 1),
                                    Color.fromRGBO(240, 240, 240, 1),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter
                                ),
                                border: Border.all(width: 1.0, color: Colors.black12),
                                borderRadius: BorderRadius.all(Radius.circular(20.0))
                              ),
                            ),
                          ),
                        )
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: _myWidget
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Color.fromRGBO(239, 239, 239, 1.0),
            ),
          )
        );
      }
    );
    
  }

}

Widget noClick() {
    return Container();
  }