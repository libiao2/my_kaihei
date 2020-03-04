import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:premades_nn/components/ClickButton.dart';
import 'package:premades_nn/components/ImageLayer.dart';
import 'package:premades_nn/components/extended_text_field.dart';
import 'package:premades_nn/components/my_special_text_span_builder.dart';
import 'package:premades_nn/event/group_event.dart';
import 'package:premades_nn/event/update_group_chat_message_event.dart';
import 'package:premades_nn/event/update_group_event.dart';
import 'package:premades_nn/event/update_message_list_event.dart';
import 'package:premades_nn/model/group_message_item_entity.dart';
import 'package:premades_nn/model/message_item_entity.dart';
import 'package:premades_nn/page/news/group_setting_screen.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/type/AddFriendStatusType.dart';
import 'package:premades_nn/type/FileType.dart';
import 'package:premades_nn/type/FriendFromType.dart';
import 'package:premades_nn/type/MessageType.dart';
import 'package:premades_nn/type/SendType.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/DBHelper.dart';
import 'package:premades_nn/utils/ImageUtil.dart';
import 'package:premades_nn/utils/PermissionHelper.dart';
import 'package:premades_nn/utils/SocketHelper.dart';
import 'package:premades_nn/utils/SoundRecordUtil.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'group_chat_message.dart';

///聊天详情页面
class GroupChatScreen extends StatefulWidget {
  int groupNo;
  String groupName;
  String avatar;

  GroupChatScreen({this.groupNo, this.groupName, this.avatar});

  @override
  _GroupChatScreen createState() => _GroupChatScreen();
}

class _GroupChatScreen extends State<GroupChatScreen> with TickerProviderStateMixin {
  List<GroupChatMessage> _messageWidgets = new List();
  TextEditingController _inputController = TextEditingController();
  ScrollController _listViewController = ScrollController();

//  String inputValue;

  int curPage = 1;
  int pageSize = 100;

  List<GroupMessageItemEntity> _messages;

  //消息监听
  StreamSubscription<UpdateGroupChatMessageEvent> _subscription;

  //发送消息 消息体
  GroupMessageItemEntity _messageItem;

  //语音消息界面显示控制
  bool _isShowSoundRecord = false;
  bool _isOnPress = false;
  String timeContent = "按住说话";

  //emoji界面显示控制
  bool _isShowEmoji = false;

  //图片界面显示控制
  bool _isShowPhoto = false;

  double listHeight;
  double titleBarHeight = ScreenUtil().setHeight(50);
  double toolHeight = ScreenUtil().setHeight(100);

  bool _isShowToolDetail = false; //是否显示工具详情

  bool isKeyboardShow = false; //是否弹出键盘了

  StreamSubscription<UpdateGroupEvent> _updateGroupSubscription;

  //清空聊天记录
  StreamSubscription<GroupEvent> _groupSubscription;

  @override
  void initState() {
    super.initState();

      listHeight = Constants.screenHeight -
          Constants.statusBarHeight -
          titleBarHeight -
          toolHeight;


    //当前页为聊天页面
    Constants.isOnGroupChatScreen = true;
    Constants.curChatGroupNo = widget.groupNo;

    //加载聊天记录
    initGroupMessage();

    //事件监听
    _subscription =
        Constants.eventBus.on<UpdateGroupChatMessageEvent>().listen((event) {
      if (event.message != null) {
        //接收消息
        //页面更新
        createMessageItem(event.message);
        //添加到数据库
        DBHelper.insertGroupMessage(event.message);

        _messageItem = event.message;

      } else {
        //发送消息成功回调
        DBHelper.insertGroupMessage(_messageItem);
      }
    });

    _updateGroupSubscription = Constants.eventBus.on<UpdateGroupEvent>().listen((event){
      if (event.type == UpdateGroupType.updateGroupName){
        if (widget.groupNo == event.groupNo){
          setState(() {
            widget.groupName = event.groupName;
          });
        }
      }
    });

    _groupSubscription = Constants.eventBus.on<GroupEvent>().listen((event){
      if (event.type == GroupEventType.clearGroupChat){
        if (widget.groupNo == event.groupNo){
          setState(() {
            _messages.clear();
            _messageWidgets.clear();
          });
        }
      }
    });

    SoundRecordUtil.initSoundRecord();
  }

  @override
  void dispose() {
    super.dispose();

    Constants.isOnGroupChatScreen = false;
    Constants.curChatGroupNo = null;

    if (_subscription != null) {
      _subscription.cancel();
    }

    if (_updateGroupSubscription != null){
      _updateGroupSubscription.cancel();
    }

    if (_groupSubscription != null){
      _groupSubscription.cancel();
    }

//    if (_messages != null && _messages.length > 0) {
//      Constants.eventBus.fire(UpdateMessageListEvent(
//          type: 0,
//          groupNo: widget.groupNo,
//          content: _messages[_messages.length - 1].content,
//          timestamp: _messages[_messages.length - 1].timestamp));
//    }

    if (_messageItem != null) {
      Constants.eventBus.fire(UpdateMessageListEvent(
          type: 0,
          groupNo: widget.groupNo,
          messageType: _messageItem.messageType,
          content: _messageItem.content,
          timestamp: _messageItem.timestamp));
    }
  }

  @override
  Widget build(BuildContext context) {
    double keyBoardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyBoardHeight != null && keyBoardHeight != 0.0) {
      isKeyboardShow = true;

      Timer(Duration(milliseconds: 100), () {
        _listViewController
            .jumpTo(_listViewController.position.maxScrollExtent);
      });
    } else {
      isKeyboardShow = false;
    }

    return Container(
      color: ColorUtil.greyBG,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Container(
              height: ScreenUtil().setHeight(50),
              margin: EdgeInsets.only(
                  top: MediaQueryData.fromWindow(window).padding.top),
              child: Row(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: ScreenUtil().setHeight(50),
                      height: ScreenUtil().setHeight(50),
                      child: Container(
                        alignment: Alignment.center,
                        width: 46,
                        height: ScreenUtil().setHeight(50),
                        child: Image.asset("images/go_back.png",
                          width: 16,height: 16,),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: ScreenUtil().setWidth(20),
                          right: ScreenUtil().setWidth(20)),
                    child: Text(
                      widget.groupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                  )),
                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return GroupSettingScreen(groupNo: widget.groupNo, groupName: widget.groupName,);
                      }));
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: ScreenUtil().setHeight(50),
                      height: ScreenUtil().setHeight(50),
                      child: Image.asset("images/icon_more.png",
                        width: ScreenUtil().setWidth(16),
                        fit: BoxFit.fitWidth,),
                    ),
                  ),

                ],
              ),
            ),
            Container(
              height: 1,
              color: Color.fromRGBO(242, 242, 242, 1),
            ),
          Stack(
            children: <Widget>[
              Container(
                color: ColorUtil.greyBG,
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        // 触摸收起键盘
                        FocusScope.of(context).requestFocus(FocusNode());
                        setState(() {
                          _isShowToolDetail = false;
                          _isShowEmoji = false;
                          _isShowPhoto = false;
                          _isShowSoundRecord = false;
                        });
                      },
                      child: Container(
                        height: _isShowToolDetail || isKeyboardShow
                            ? listHeight - Constants.keyBoardHeight
                            : listHeight,

                        child: ListView.separated(
                          physics: BouncingScrollPhysics(),
                          controller: _listViewController,
                          itemCount: _messageWidgets.length,
                          itemBuilder: (_, int index) => _messageWidgets[index],
                          separatorBuilder: (context, index) {
                            return Center();
                          },
                          // reverse: true,
                        ),
                      ),
                    ),
//                  ),
                    toolBar()
                  ],
                ),
              ),

            ],
          ),
          ],
        ),
      ),
    );
  }

  AnimationController controller;
  Animation<double> animation;
  String curFilePath;

  Widget toolBar() {
    controller = AnimationController(
      duration: Duration(milliseconds: 300), //new  动画持续时间
      vsync: this, //new  默认属性和参数
    );

    animation = Tween(begin: 1.0, end: 0.8).animate(controller);

    return Container(
      color: ColorUtil.white,
      height: _isShowToolDetail || isKeyboardShow
          ? Constants.keyBoardHeight + toolHeight
          : toolHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          chatInput(),
          toolsBtn(),
          Expanded(
              child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Offstage(
                offstage: !_isShowSoundRecord,
                child: Container(
                  width: double.infinity,
                  height: Constants.keyBoardHeight,
                  color: Color.fromRGBO(242, 242, 242, 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
                        child: Text(
                          timeContent,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                      ScaleTransition(
                        scale: animation,
                        child: GestureDetector(
                          onLongPress: () async {
                            controller.forward();
                            curFilePath =
                                await SoundRecordUtil.startRecorder((time) {
                              int minute = (time / 60).floor();
                              int second = time - minute * 60;
                              String minuteStr;
                              String secondStr;

                              if (minute < 10 && minute > 0) {
                                minuteStr = "0$minute";
                              } else if (minute == 0) {
                                minuteStr = "00";
                              } else {
                                minuteStr = minute.toString();
                              }

                              if (second < 10 && second > 0) {
                                secondStr = "0$second";
                              } else if (second == 0) {
                                secondStr = "00";
                              } else {
                                secondStr = second.toString();
                              }
                              setState(() {
                                timeContent = minuteStr + ":" + secondStr;
                              });
                            });
                          },
                          onLongPressUp: () async {
                            print("onLongPressUp");
                            controller.reverse();
                            int time = await SoundRecordUtil.stopRecorder();

                            File file = File(curFilePath);
                            if (curFilePath != null &&
                                file != null &&
                                await file.exists()) {
                              ImageUtil.uploadImg(file,
                                      fileType: FileType.AUDIO)
                                  .then((res) {
                                var resData = res['data'];
                                String url = resData['url'];
                                if (res['code'] == 0) {
                                  SocketHelper.sendGroupMessage(
                                      widget.groupNo,
                                      url,
                                      MessageType.RECORD,
                                      DateTime.now().millisecondsSinceEpoch,
                                      voiceDuration: time);

                                  int timestamp = DateTime.now().millisecondsSinceEpoch;
                                  _messageItem =
                                      GroupMessageItemEntity(
                                          fromNnid: Constants.userInfo.nnId,
                                          fromAvatar: Constants.userInfo.avatar,
                                          fromNickname: Constants.userInfo.nickname,
                                          groupNo: widget.groupNo,
                                          content: url,
                                          timestamp: timestamp,
                                          messageType: MessageType.RECORD,
                                          sequenceId: timestamp,
                                          sendType: SendType.SEND_SUCCESS,
                                          extra: ExtraData(voiceDuration: time),
                                          isRead: false);
//
//                                  createMessageItem(_messageItem);

                                  timeContent = "按住说话";
                                }
                              }).catchError((e) {
                                print(e.toString());
                              });
                            }
                          },
                          onLongPressMoveUpdate: (detail) {
                            if (detail.localPosition.dy < 0) {
                            } else {}
                            print(
                                "onLongPressMoveUpdate: ${detail.localPosition.dx}, ${detail.localPosition.dy}");
                          },
                          child: Image.asset(
                            "images/btn_voice.png",
                            width: 100,
                            height: 100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Offstage(
                  offstage: !_isShowEmoji,
                  child: Container(
                    color: Color.fromRGBO(242, 242, 242, 1),
                    height: Constants.keyBoardHeight,
                    margin: EdgeInsets.only(top: 5),
                    child: GridView.count(
                      //水平子Widget之间间距
                      crossAxisSpacing: 5,
                      //垂直子Widget之间间距
                      mainAxisSpacing: 5,
                      //一行的Widget数量
                      crossAxisCount: 7,
                      //子Widget宽高比例
                      childAspectRatio: 1,
                      //子Widget列表
                      children: getEmojiList(),
                    ),
                  )),
              Offstage(
                offstage: !_isShowPhoto,
                child: Column(
                  children: <Widget>[
                    Container(
                      height: Constants.keyBoardHeight - ScreenUtil().setHeight(50),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: assetList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return photoItem(assetList[index]);
                        },
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              PermissionHelper.checkPermission(
                                  context,
                                  "需要存储权限查看手机相册图片，是否前往打开应用权限？",
                                  PermissionGroup.storage, () async {
                                List<AssetEntity> resultList =
                                    await PhotoPicker.pickAsset(
                                        context: context,
                                        pickType: PickType.onlyImage);
                                resultList.forEach((assetEntity) async {
                                  File imageFile = await assetEntity.file;
                                  ImageUtil.uploadImg(imageFile)
                                      .then((response) {
                                    if (response != null &&
                                        response["code"] == 0) {
                                      String url = response['data']['url'];

                                      int timestamp =
                                          DateTime.now().millisecondsSinceEpoch;
                                      //发送图片 socket信息
                                      SocketHelper.sendGroupMessage(widget.groupNo, url,
                                          MessageType.IMAGE, timestamp);

                                      _messageItem =
                                          GroupMessageItemEntity(
                                              fromNnid: Constants.userInfo.nnId,
                                              fromAvatar: Constants.userInfo.avatar,
                                              fromNickname: Constants.userInfo.nickname,
                                              groupNo: widget.groupNo,
                                              content: url,
                                              timestamp: DateTime.now().millisecondsSinceEpoch,
                                              messageType: MessageType.IMAGE,
                                              sequenceId: timestamp,
                                              sendType: SendType.SENDING,
                                              extra: ExtraData(imageWidth: assetEntity.width, imageHeight: assetEntity.height),
                                              isRead: false);
//
//                                      createMessageItem(_messageItem);
                                    }
                                  });
                                });
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "相册",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (Constants.selectedList != null &&
                                  Constants.selectedList.length > 0) {
                                Constants.selectedList
                                    .forEach((assetEntity) async {
                                  File imageFile = await assetEntity.file;
                                  ImageUtil.uploadImg(imageFile)
                                      .then((response) {
                                    if (response != null &&
                                        response["code"] == 0) {
                                      String url = response['data']['url'];

                                      int timestamp =
                                          DateTime.now().millisecondsSinceEpoch;
                                      //发送图片 socket信息
                                      SocketHelper.sendGroupMessage(widget.groupNo, url,
                                          MessageType.IMAGE, timestamp);

                                      _messageItem =
                                          GroupMessageItemEntity(
                                              fromNnid: Constants.userInfo.nnId,
                                              fromAvatar: Constants.userInfo.avatar,
                                              fromNickname: Constants.userInfo.nickname,
                                              groupNo: widget.groupNo,
                                              content: url,
                                              timestamp: DateTime.now().millisecondsSinceEpoch,
                                              messageType: MessageType.IMAGE,
                                              sequenceId: timestamp,
                                              sendType: SendType.SENDING,
                                              extra: ExtraData(imageWidth: assetEntity.width, imageHeight: assetEntity.height),
                                              isRead: false);
//
//                                      createMessageItem(_messageItem);
                                    }
                                  });
                                  Constants.selectedList.clear();
                                });
                              } else {
                                Fluttertoast.showToast(
                                    msg: "请选择图片！",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIos: 1,
                                    backgroundColor: Colors.black54,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 10),
                              padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                              child: Text(
                                "发送",
                                style: TextStyle(color: Colors.white),
                              ),
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  gradient: LinearGradient(
                                    colors: [ColorUtil.btnStartColor, ColorUtil.btnEndColor],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  ///返回emoji组件集合
  List<Widget> getEmojiList() {
    return getDataList().map((item) => getItemContainer(item)).toList();
  }

  final int emojiNum = 19; //个数

  ///emoji数据
  List<String> getDataList() {
    List<String> list = [];
    for (int i = 1; i <= emojiNum; i++) {
      if (i < 10) {
        list.add("images/emoji/e1000$i.png");
      } else if (i >= 10 && i < 100) {
        list.add("images/emoji/e100$i.png");
      } else {
        list.add("images/emoji/e10$i.png");
      }
    }
    return list;
  }

  //images/emoji/e10005.png
  ///emoji表情组件
  Widget getItemContainer(String item) {
    return InkWell(
      onTap: () {
        String emojiName =
            item.substring(item.lastIndexOf("/") + 1, item.indexOf("."));
        _inputController.text = _inputController.text + "<em>$emojiName</em>";
      },
      child: Container(
        alignment: Alignment.center,
        child: Image.asset(
          '$item',
          width: 30,
          height: 30,
        ),
      ),
    );
  }

  ///输入组件
  Widget chatInput() {
    return Container(
      alignment: Alignment.center,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
                alignment: Alignment.center,
            height: ScreenUtil().setHeight(40),
            margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
            decoration: BoxDecoration(
              color: Color.fromRGBO(242, 242, 242, 1),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: ExtendedTextField(
              specialTextSpanBuilder: MySpecialTextSpanBuilder(),
              controller: _inputController,
              autofocus: false,
              maxLines: 1,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  hintText: '说点什么吧...',
                  hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: ScreenUtil.getInstance().setSp(14)),
                  border: OutlineInputBorder(
                      // borderRadius: BorderRadius.circular(15.0),
                      borderSide: BorderSide.none)),
//              onChanged: _onChanged,
              onTap: () {},
              onSubmitted: _handleSubmitted,
            ),
          )),
        ],
      ),
    );
  }

  ///工具栏 语音消息-表情-语音通话-手机图片-拍照
  Widget toolsBtn() {
    return Container(
      height: ScreenUtil().setHeight(50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          //语音消息
          iconBtn(
            imageUrl: _isShowEmoji?"images/icon_voice_on.png":"images/icon_voice.png",
            onPressed: () {
              PermissionHandler().requestPermissions([
                PermissionGroup.storage,
                PermissionGroup.microphone
              ]).then((permissions) {
                int count = 0;
                permissions.forEach((key, value) {
                  if (key == PermissionGroup.storage &&
                      value == PermissionStatus.granted) {
                    count++;
                  } else if (key == PermissionGroup.microphone &&
                      value == PermissionStatus.granted) {
                    count++;
                  }
                });

                if (count == 2) {
                  setState(() {
                    _isShowSoundRecord = !_isShowSoundRecord;
                    _isShowToolDetail = _isShowSoundRecord;
                    _isShowEmoji = false;
                    _isShowPhoto = false;

                    Timer(Duration(milliseconds: 100), () {
                      _listViewController
                          .jumpTo(_listViewController.position.maxScrollExtent);
                    });
                  });
                }
              });
            },
          ),
          //表情
          iconBtn(
            imageUrl: "images/icon_emoji.png",
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              setState(() {
                _isShowEmoji = !_isShowEmoji;
                _isShowPhoto = false;
                _isShowSoundRecord = false;
                _isShowToolDetail = _isShowEmoji;
                Timer(Duration(milliseconds: 100), () {
                  _listViewController
                      .jumpTo(_listViewController.position.maxScrollExtent);
                });
              });
            },
          ),

          //手机图片
          iconBtn(
            imageUrl: "images/icon_pic.png",
            onPressed: () {
              FocusScope.of(context).requestFocus(FocusNode());
              setState(() {
                _isShowPhoto = !_isShowPhoto;
                _isShowToolDetail = _isShowPhoto;
                _isShowEmoji = false;
                _isShowSoundRecord = false;
                Timer(Duration(milliseconds: 100), () {
                  _listViewController
                      .jumpTo(_listViewController.position.maxScrollExtent);
                });
              });
              getPhotos();
            },
          ),
          //拍照
          iconBtn(
            imageUrl: "images/icon_photo.png",
            onPressed: () {
              PermissionHelper.checkPermission(
                  context, "需要拍照权限，是否前往打开应用权限？", PermissionGroup.camera,
                  () async {
                File image =
                    await ImagePicker.pickImage(source: ImageSource.camera);

                ImageUtil.uploadImg(image).then((response) {
                  if (response != null && response["code"] == 0) {
                    String url = response['data']['url'];

                    int timestamp = DateTime.now().millisecondsSinceEpoch;
                    //发送图片 socket信息
                    SocketHelper.sendGroupMessage(
                        widget.groupNo, url, MessageType.IMAGE, timestamp);

                    _messageItem = GroupMessageItemEntity(
                        fromNnid: Constants.userInfo.nnId,
                        fromAvatar: Constants.userInfo.avatar,
                        fromNickname: Constants.userInfo.nickname,
                        groupNo: widget.groupNo,
                        content: url,
                        timestamp: DateTime.now().millisecondsSinceEpoch,
                        messageType: MessageType.IMAGE,
                        sequenceId: timestamp,
                        sendType: SendType.SENDING,
                        extra: ExtraData(imageWidth: (ScreenUtil().setWidth(100) as double).floor(),
                            imageHeight: (ScreenUtil().setHeight(100) as double).floor()),
                        isRead: false);
//
//                    createMessageItem(_messageItem);
                  }
                });
              });
            },
          ),

          ClickButton(
              text: Strings.send,
              margin: EdgeInsets.only(right: ScreenUtil().setWidth(10)),
              width: ScreenUtil().setHeight(80),
              height: ScreenUtil().setHeight(40),
              textSize: ScreenUtil().setSp(14),
              clickCallback: () {
                _handleSubmitted(_inputController.text);
              }),

//          Container(
//            alignment: Alignment.center,
//            margin: EdgeInsets.only(right: 10,left: ScreenUtil().setHeight(40)),
//            height: ScreenUtil().setHeight(40),
//            width: ScreenUtil().setHeight(80),
//            decoration: BoxDecoration(
//              gradient: LinearGradient(
//                colors: [ColorUtil.btnStartColor, ColorUtil.btnEndColor],
//                begin: Alignment.topCenter,
//                end: Alignment.bottomCenter,
//              ),
//              borderRadius: BorderRadius.all(Radius.circular(20)),
//            ),
//            child: InkWell(
//              child: Text(
//                '发送',
//                style: TextStyle(
//                    color: Colors.white, fontSize: ScreenUtil().setSp(14)),
//              ),
//              onTap: () {
//                _handleSubmitted(_inputController.text);
//              },
//            ),
//          ),
        ],
      ),
    );
  }

  ///工具组件
  Widget iconBtn({imageUrl, onPressed}) {
    return InkWell(
      child: Container(
        child: Image.asset(imageUrl, width: ScreenUtil().setWidth(37),fit: BoxFit.fitWidth,),
        decoration: BoxDecoration(
            color: Color.fromRGBO(242, 242, 242, 1), shape: BoxShape.circle),
        width: ScreenUtil().setHeight(37),
      ),
      onTap: () {
        onPressed();
      },
    );
  }

  ///发送消息
  Future _handleSubmitted(String text) async {
    if (text == "") return;

    if (text.length > 200) {
      Fluttertoast.showToast(
          msg: "您输入的字符已超过200！",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    int timestamp = DateTime.now().millisecondsSinceEpoch;

    SocketHelper.sendGroupMessage(widget.groupNo, text, MessageType.TEXT, timestamp);

    setState(() {
      _inputController.text = "";
    });

    _messageItem = GroupMessageItemEntity(
        fromNnid: Constants.userInfo.nnId,
        fromAvatar: Constants.userInfo.avatar,
        fromNickname: Constants.userInfo.nickname,
        groupNo: widget.groupNo,
        content: text,
        timestamp: timestamp,
        messageType: MessageType.TEXT,
        isRead: false);
//    createMessageItem(_messageItem);
  }

  ///获取聊天记录
  Future initGroupMessage() async {
    if (Constants.connected) {
      //网络上获取数据
      var data = {"groups_no": widget.groupNo, "last_id": 0, "limit": 100};
      request("post", allUrl["groupMessages"], data).then((result) {
        if (result["code"] == 0 && result["data"]["list"] != null) {
          _messages = new List<GroupMessageItemEntity>();
          List tempList = result["data"]["list"] as List;
          for (int i = tempList.length - 1; i >= 0; i--) {
            _messages.add(GroupMessageItemEntity.fromJson(tempList[i]));
          }

          //网络上获取数据就刷新数据库
          DBHelper.insertGroupMessages(_messages, widget.groupNo);

          updateView();
        }
      });
    } else {
      //数据库读取数据
      _messages = await DBHelper.queryGroupMessagesByGroupNo(widget.groupNo);

      updateView();
    }
  }

  ///更新页面
  void updateView() {
    if (_messageWidgets == null && _messageWidgets.length > 0) {
      _messageWidgets.clear();
    }

    if (_messages != null && _messages.length > 0) {
      _messages.forEach((messageItem) {
        GroupChatMessage chatMessage = new GroupChatMessage(
          messageItem: messageItem,
          avatar: widget.avatar
        );
        _messageWidgets.add(chatMessage);
      });

      setState(() {
        Timer(Duration(milliseconds: 100), () {
          _listViewController
              .jumpTo(_listViewController.position.maxScrollExtent);
        });
      });
    }
  }

  ///创建消息item 发送消息 和 socket监听获取消息
  void createMessageItem(GroupMessageItemEntity itemEntity) {
    GroupChatMessage message = GroupChatMessage(
      messageItem: itemEntity,
      avatar: widget.avatar,
      animationController: AnimationController(
        duration: Duration(milliseconds: 300), //new  动画持续时间
        vsync: this, //new  默认属性和参数
      ), //new
    );

    //new
    setState(() {
      _messageWidgets.insert(_messageWidgets.length, message);
    });

    Timer(Duration(milliseconds: 100), () {
      _listViewController.jumpTo(_listViewController.position.maxScrollExtent);
      message.animationController.forward(); // 启动动画
    });

//    SocketHelper.markMessageRead(widget.id);
  }

  List<AssetEntity> assetList = List();
  List<AssetPathEntity> pathList = List();

  void getPhotos() {
    PermissionHelper.checkPermission(
        context, "需要麦存储权限权限，是否前往打开应用权限？", PermissionGroup.storage, () async {
      pathList = await PhotoManager.getImageAsset();
      assetList = await pathList[0].assetList;
      setState(() {});
    });
  }

//  double imageHeight = Constants.keyBoardHeight - 50;

  Widget photoItem(AssetEntity assetEntity) {
    int height = Constants.keyBoardHeight.floor() - 50;
    int width = ((Constants.keyBoardHeight - 50) *
            assetEntity.width /
            assetEntity.height)
        .floor();

    if (width < 80) {
      width = 80;
    }
    return FutureBuilder<Uint8List>(
      future: assetEntity.thumbDataWithSize(height, width),
      builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
        var futureData = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done &&
            futureData != null) {
//          ImageLruCache.setData(entity, size, futureData);
          return Container(
            width: width.ceilToDouble(),
            height: (Constants.keyBoardHeight - 50),
            child: Stack(
              alignment: Alignment.topRight,
              children: <Widget>[
                _buildImageItem(context, futureData, assetEntity),
                ImageLayer(assetEntity: assetEntity),
              ],
            ),
          );
        }
        return Center(
          child: DefaultLoadingDelegate().buildPreviewLoading(
            context,
            assetEntity,
            Colors.grey,
          ),
        );
      },
    );
  }

  Widget _buildImageItem(
      BuildContext context, Uint8List data, AssetEntity assetEntity) {
    double width = (Constants.keyBoardHeight - 50) /
        assetEntity.height *
        assetEntity.width;

    if (width < 80.0) {
      width = 80.0;
    }

    var image = Image.memory(
      data,
      width: width,
      height: (Constants.keyBoardHeight - 50),
      fit: BoxFit.fitWidth,
    );
    var badge = Container();

    return Stack(
      children: <Widget>[
        image,
        IgnorePointer(
          child: badge,
        ),
      ],
    );
  }

  ///添加好友
  Future addFriend(int nnId) async {

    Fluttertoast.showToast(
        msg: "好友请求已发送！",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0);

    SocketHelper.addFriend(nnId, AddFriendStatusType.addFriend, "",
        FriendFromType.fromSearch);
  }
}
