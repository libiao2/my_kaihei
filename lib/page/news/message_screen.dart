import 'dart:async';
import 'dart:math';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/components/CustomDialog.dart';
import 'package:premades_nn/components/my_special_text_span_builder.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/event/add_friend_event.dart';
import 'package:premades_nn/event/group_event.dart';
import 'package:premades_nn/event/system_notice_event.dart';
import 'package:premades_nn/event/update_group_event.dart';
import 'package:premades_nn/event/update_message_helper_event.dart';
import 'package:premades_nn/event/update_message_list_event.dart';
import 'package:premades_nn/event/update_screen_event.dart';
import 'package:premades_nn/event/update_unread_event.dart';
import 'package:premades_nn/model/list_message_entity.dart';
import 'package:premades_nn/model/system_message_entity.dart';
import 'package:premades_nn/page/news/system_notice_screen.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/type/MessageType.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/Constants.dart' as prefix0;
import 'package:premades_nn/utils/DBHelper.dart';
import 'package:premades_nn/utils/SocketHelper.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'group_chat_screen.dart';
import 'message_helper.dart';
import 'chat_screen.dart';
import '../../service/service_url.dart';

///消息列表页面
class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<ListMessageEntity> messageList = new List();

  StreamSubscription<UpdateMessageListEvent> _subscription;

  //消息助手 监听
  StreamSubscription<UpdateMessageHelperEvevt> _messageHelperSubscription;

  //系统公告
  StreamSubscription<SystemNoticeEvent> _systemNoticeSubscription;

  //添加好友成功监听 修改回话数据并更新本地数据库
  StreamSubscription<AddFriendSuccessEvent> _screenUpdateSubscription;

  List<SystemMessageEntity> messageHelperList = List();

  //修改群聊名称
  StreamSubscription<UpdateGroupEvent> _updateGroupSubscription;

//  StreamSubscription<AddFriendEvent> _UpdateFrinendsubscription;

  //清空聊天记录
  StreamSubscription<GroupEvent> _groupSubscription;

  @override
  void initState() {
    super.initState();

    Constants.isOnMessageScreen = true;

    loadMessageList();

//    initMessageHelperData();

    _subscription =
        Constants.eventBus.on<UpdateMessageListEvent>().listen((event) {
      bool isHave = false;
      for (int i = 0; i < messageList.length; i++) {
        if (event.nnId != null) {
          if (messageList[i].nnId == event.nnId) {
            isHave = true;
            setState(() {
              messageList[i].content = event.content;
              messageList[i].timestamp = event.timestamp;
              messageList[i].messageType = event.messageType;
              if (event.type != 0) {
                if (event.type == 1) {
                  messageList[i].unreadCount++;
                }
                DBHelper.updateChat(messageList[i]);
              }
            });
            break;
          }
        } else if (event.groupNo != null) {
          if (messageList[i].groupsNo == event.groupNo) {
            isHave = true;
            setState(() {
              messageList[i].content = event.content;
              messageList[i].timestamp = event.timestamp;
              if (event.type == 1) {
                messageList[i].unreadCount++;
                DBHelper.updateChat(messageList[i]);
              }
            });
            break;
          }
        }
      }

      if (!isHave) {
        setState(() {
          event.listMessage.unreadCount = 1;
          messageList.insert(0, event.listMessage);
        });
      }
    });

    //消息助手
    _messageHelperSubscription =
        Constants.eventBus.on<UpdateMessageHelperEvevt>().listen((event) {
      setState(() {
        if (event.status == 1) {
          Constants.systemMessageCount++;
          Constants.systemMessageLastContent = "${event.nickName}请求添加您为好友";
        } else if (event.status == 2) {
          Constants.systemMessageLastContent = "${event.nickName}已成为您的好友";
        } else if (event.status == 5){
          Constants.systemMessageLastContent = "";
        }
      });
    });


    //系统公告
    _systemNoticeSubscription =
        Constants.eventBus.on<SystemNoticeEvent>().listen((event) {
          setState(() {
            Constants.systemNoticeCount++;
            Constants.systemNoticeLastContent = event.title;
          });
    });

    //添加好友成功
    _screenUpdateSubscription =
        Constants.eventBus.on<AddFriendSuccessEvent>().listen((event) {
      for (int i = 0; i < messageList.length; i++) {
        if (messageList[i].nnId == event.nnID) {
          messageList[i].isFriend = true;
        }
      }
    });

    //清空聊天记录
    _groupSubscription =
        Constants.eventBus.on<GroupEvent>().listen((event) {
      if (event.type == GroupEventType.clearGroupChat){
        messageList.forEach((messageItem){
          if (event.groupNo == messageItem.groupsNo){
            setState(() {
              messageItem.content = "";
            });
          }
        });
      }
    });

    //群组更新
    _updateGroupSubscription = Constants.eventBus.on<UpdateGroupEvent>().listen((event){
      if (event.type == UpdateGroupType.updateGroupName){
        messageList.forEach((item){
          if (item.groupsNo == event.groupNo){
            setState(() {
              item.groupsName = event.groupName;
            });
          }
        });
      }
    });

//    _UpdateFrinendsubscription = Constants.eventBus.on<AddFriendEvent>().listen((event) {
//      if (event.type == FriendInfoUpdateType.updateRemark) {
//        messageList.forEach((item){
//          if (item.nnId == event.nnId && item.friendInfo != null){
//            setState(() {
//              item.friendInfo["friend_remark"] = event.remark;
//            });
//          }
//        });
//      }
//    });
  }

  @override
  void dispose() {
    super.dispose();

    Constants.isOnMessageScreen = false;

    if (_subscription != null) {
      _subscription.cancel();
    }

    if (_messageHelperSubscription != null) {
      _messageHelperSubscription.cancel();
    }
    if (_screenUpdateSubscription != null) {
      _screenUpdateSubscription.cancel();
    }

    if (_updateGroupSubscription != null) {
      _updateGroupSubscription.cancel();
    }

    if (_systemNoticeSubscription != null) {
      _systemNoticeSubscription.cancel();
    }

//    if (_UpdateFrinendsubscription != null) {
//      _UpdateFrinendsubscription.cancel();
//    }
  }

  ///加载聊天消息
  void loadMessageList() {
    if (messageList.length > 0) {
      messageList.clear();
    }

    if (Constants.connected) {
      request('post', allUrl['group_user_recent_contacts'], null).then((val) {
        if (val['code'] == 0 && val['data'] != null) {
          setState(() {
            if (val['data'] != null) {
              (val['data'] as List).forEach((item) {
                if (item["contact"] != null && item["contact"] != "") {
                  messageList.add(ListMessageEntity.fromJson(item["contact"]));
                } else if (item["groups"] != null && item["groups"] != "") {
                  messageList
                      .add(ListMessageEntity.fromGroupJson(item["groups"]));
                }
              });

              messageList.forEach((message) {
                if (message.friendInfo != null) {
                  message.isFriend = true;
                } else {
                  message.isFriend = false;
                }
              });

              DBHelper.insertChats(messageList);
            }
//          messageList = val['data']['list'] == null ? [] : val['data']['list'];
          });
        }
      });
    } else {
      DBHelper.queryAllChat().then((list) {
        if (list != null && list.length > 0) {
          setState(() {
            messageList.addAll(list);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            systemMessage(),
            notice(),
            Column(
              children: message(),
            )
          ],
        ),
      ),
      color: ColorUtil.greyBG,
    );
  }

  ///系统公告
  Widget systemMessage() {
    return Container(
      height: ScreenUtil().setHeight(63),
      padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(10), right: ScreenUtil().setWidth(10)),
      child: InkWell(
        child: Row(
          children: <Widget>[
            Container(
                width: ScreenUtil().setWidth(44),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipOval(
                    child: Image.asset(
                      "images/icon_system_message.png",
                    ),
                  ),
                )),
            Expanded(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(
                          top: ScreenUtil().setHeight(12),
                          left: ScreenUtil().setHeight(10)),
                      child: Text(
                        "系统公告",
                        style: TextStyle(
                            fontSize: ScreenUtil.getInstance().setSp(15),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(
                          top: ScreenUtil().setHeight(5),
                          left: ScreenUtil().setWidth(10)),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: Text(
                                Constants.systemNoticeLastContent == null
                                    ? ""
                                    : Constants.systemNoticeLastContent,
                                style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(12),
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Offstage(
                            offstage: Constants.systemNoticeCount == 0,
                            child: Container(
                              margin: EdgeInsets.only(right: 10),
                              padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                              child: Text(
                                Constants.systemNoticeCount > 99
                                    ? '99+'
                                    : Constants.systemNoticeCount.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(12)),
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        onTap: () {
          Constants.eventBus
              .fire(UpdateUnreadEvent(num: Constants.systemNoticeCount));
          Constants.systemNoticeCount = 0;
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return SystemNoticeScreen();
          }));
        },
      ),
      decoration: BoxDecoration(
        color: ColorUtil.white,
        border: Border(bottom: BorderSide(color: ColorUtil.lineGrey, width: ScreenUtil().setHeight(1))),
      ),
    );
  }

  ///消息助手
  Widget notice() {
    return Container(
      height: ScreenUtil().setHeight(63),
      padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(10), right: ScreenUtil().setWidth(10)),
      child: InkWell(
        child: Row(
          children: <Widget>[
            Container(
                width: ScreenUtil().setWidth(44),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipOval(
                    child: Image.asset(
                      "images/icon_message_helper.png",
                    ),
                  ),
                )),
            Expanded(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(
                          top: ScreenUtil().setHeight(12),
                          left: ScreenUtil().setWidth(10)),
                      child: Text(
                        "消息助手",
                        style: TextStyle(
                            fontSize: ScreenUtil.getInstance().setSp(15),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(
                          top: ScreenUtil().setHeight(5),
                          left: ScreenUtil().setWidth(10)),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              child: Text(
                                Constants.systemMessageLastContent == null
                                    ? ""
                                    : Constants.systemMessageLastContent,
                                style: TextStyle(
                                  fontSize: ScreenUtil.getInstance().setSp(12),
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          Offstage(
                            offstage: Constants.systemMessageCount == 0,
                            child: Container(
                              margin: EdgeInsets.only(right: 10),
                              padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                              child: Text(
                                Constants.systemMessageCount > 99
                                    ? '99+'
                                    : Constants.systemMessageCount.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(12)),
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        onTap: () {
          Constants.eventBus
              .fire(UpdateUnreadEvent(num: Constants.systemMessageCount));
          Constants.systemMessageCount = 0;
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return MessageHelper();
          }));
        },
      ),
      decoration: BoxDecoration(
        color: ColorUtil.white,
        border: Border(bottom: BorderSide(color: ColorUtil.lineGrey, width: ScreenUtil().setHeight(1))),
      ),
    );
  }

  /// 消息列表
  List<Widget> message() {
    List<Widget> list = [];
    messageList.forEach((item) {
      list.add(messageItem(item));
    });
    return list;
  }

  double pointDownX;
  double pointDownY;

  /// 消息列表 item
  Widget messageItem(ListMessageEntity item) {
    ScrollController scrollController = ScrollController();
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          Listener(
            onPointerDown: (downEvent) {
              pointDownX = downEvent.position.dx;
              pointDownY = downEvent.position.dy;
            },
            onPointerUp: (upEvent) {
              if (upEvent.position.dx - pointDownX > 0) {
                if (upEvent.position.dx - pointDownX >
                    ScreenUtil().setWidth(50)) {
                  scrollController.jumpTo(0);
                } else {
                  scrollController
                      .jumpTo(scrollController.position.maxScrollExtent);
                }
              } else {
                if (pointDownX - upEvent.position.dx >
                    ScreenUtil().setWidth(50)) {
                  scrollController
                      .jumpTo(scrollController.position.maxScrollExtent);
                } else {
                  scrollController.jumpTo(0);
                }
              }
            },
            child: Container(
              width: ScreenUtil().setWidth(375),
              height: ScreenUtil().setWidth(63),
              padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(10),
                  right: ScreenUtil().setWidth(10)),
              decoration: BoxDecoration(
                  color: ColorUtil.white,
                  border: Border(
                      bottom: BorderSide(color: ColorUtil.lineGrey, width: ScreenUtil().setWidth(1)))),
              child: InkWell(
                child: Row(
                  children: <Widget>[avatar(item), messageInfo(item)],
                ),
                onTap: () {
                  Constants.eventBus
                      .fire(UpdateUnreadEvent(num: item.unreadCount));
                  item.unreadCount = 0;

                  if (item.messageCategory == 1) {
                    String userName;
                    if (item.friendInfo != null && item.friendInfo["friend_remark"] != null
                        && item.friendInfo["friend_remark"] != ""){
                      userName = item.friendInfo["friend_remark"];
                    } else {
                      userName = item.nickname;
                    }
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ChatScreen(
                          nnId: item.nnId,
                          userName: userName,
                          avatar: item.avatar,
                          isFriend: item.isFriend);
                    }));
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return GroupChatScreen(
                        groupNo: item.groupsNo,
                        groupName: item.groupsName,
                        avatar: item.avatar,
                      );
                    }));
                  }
                },
              ),
            ),
          ),
          InkWell(
            onTap: () {
              if (item.messageCategory == 1){
                deleteMessagesById(item, scrollController);
              } else if (item.messageCategory == 0){
                deleteGroupMessageByGroupNo(item, scrollController);
              }

            },
            child: Container(
              alignment: Alignment.center,
              height: ScreenUtil().setWidth(63),
              width: ScreenUtil().setWidth(63),
              color: Colors.red,
              child: Text(
                Strings.delete,
                style: TextStyle(
                    color: ColorUtil.white, fontSize: ScreenUtil().setSp(15)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///头像
  Widget avatar(ListMessageEntity item) {
    return Container(
        width: ScreenUtil().setWidth(44),
        child: AspectRatio(
            aspectRatio: 1,
            child: ClipOval(
              child: Image.network(
                item.avatar,
              ),
            )));
  }

  /// 消息信息
  Widget messageInfo(ListMessageEntity item) {

    String itemName;
    if (item.messageCategory == 1){
      if (item.friendInfo != null && item.friendInfo["friend_remark"] != null
          && item.friendInfo["friend_remark"] != ""){
        itemName = item.friendInfo["friend_remark"];
      } else {
        itemName = item.nickname;
      }
    } else {
      itemName = item.groupsName;
    }

    return Expanded(
        child: Container(
      height: ScreenUtil().setHeight(63),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
                top: ScreenUtil().setHeight(12),
                left: ScreenUtil().setWidth(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Text(
                      itemName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: ScreenUtil().setSp(15))),
                ),

                Container(
                  child: Text(Constants.showContentByTime(item.timestamp),
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(12),
                          color: Colors.grey)),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(
                top: ScreenUtil().setHeight(5),
                left: ScreenUtil().setWidth(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    child: ExtendedText(
                        MessageType.getContentByMessageType(
                            item.messageType, item.content),
                        maxLines: 1,
                        style: TextStyle(
                            color: ColorUtil.grey,
                            fontSize: ScreenUtil().setSp(12)),
                        overflow: TextOverflow.ellipsis,
                        specialTextSpanBuilder: MySpecialTextSpanBuilder()),
                  ),
                ),
                Offstage(
                  offstage: item.unreadCount == 0,
                  child: Container(
                    margin: EdgeInsets.only(right: 10),
                    padding: EdgeInsets.fromLTRB(5, 1, 5, 1),
                    child: Text(
                      item.unreadCount > 99
                          ? '...'
                          : item.unreadCount.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(12)),
                    ),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }

  ///删除单聊记录
  void deleteMessagesById( ListMessageEntity item, ScrollController scrollController) {
    MyDialog.showCustomDialog(
        context,
        MyDialog(
          content: "确认删除该聊天吗？",
          confirmCallback: () {
            scrollController.jumpTo(0);

            SocketHelper.deleteContact(item.nnId);

            toast("删除成功！");
            Fluttertoast.showToast(
                msg: "删除成功！",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0);

            Constants.eventBus.fire(UpdateUnreadEvent(num: item.unreadCount));

            setState(() {
              messageList.removeWhere((value) {
                return value.nnId == item.nnId;
              });
            });

            DBHelper.deleteChat(nnId: item.nnId);

          },
        ));
  }

  ///删除群聊记录
  void deleteGroupMessageByGroupNo(ListMessageEntity item, ScrollController scrollController){
    MyDialog.showCustomDialog(
        context,
        MyDialog(
          content: "确认删除该聊天吗？",
          confirmCallback: () {
            scrollController.jumpTo(0);

            SocketHelper.deleteGroupContact(item.groupsNo);

            toast("删除成功！");
            Fluttertoast.showToast(
                msg: "删除成功！",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIos: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0);

            Constants.eventBus.fire(UpdateUnreadEvent(num: item.unreadCount));

            setState(() {
              messageList.removeWhere((value) {
                return value.groupsNo == item.groupsNo;
              });
            });

            DBHelper.deleteChat(groupNo: item.groupsNo);

          },
        ));
  }
}
