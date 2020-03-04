import 'dart:convert';
import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:premades_nn/event/add_room.dart';
import 'package:premades_nn/event/relogin_event.dart';
import 'package:premades_nn/event/system_notice_event.dart';
import 'package:premades_nn/event/socket_is_broken.dart';
import 'package:premades_nn/event/update_group_chat_message_event.dart';
import 'package:premades_nn/event/update_group_event.dart';
import 'package:premades_nn/model/group_entity.dart';
import 'package:premades_nn/model/group_message_item_entity.dart';
import 'package:premades_nn/plugin/FloatWindow.dart';
import 'package:premades_nn/plugin/HeartBeatPlugin.dart';
import 'package:premades_nn/type/VoiceStatusType.dart';
import 'package:premades_nn/utils/Constants.dart' as prefix0;
import 'package:provide/provide.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/event/add_friend_event.dart';
import 'package:premades_nn/event/update_chat_message_event.dart';
import 'package:premades_nn/event/update_message_helper_event.dart';
import 'package:premades_nn/event/update_message_list_event.dart';
import 'package:premades_nn/event/update_screen_event.dart';
import 'package:premades_nn/event/update_unread_event.dart';
import 'package:premades_nn/event/voice_call_state_event.dart';
import 'package:premades_nn/model/list_message_entity.dart';
import 'package:premades_nn/model/message_item_entity.dart';
import 'package:premades_nn/type/MessageType.dart';
import 'package:premades_nn/type/SendType.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../main.dart';
import '../provide/storeData.dart';
import '../components/toast.dart';
import '../provide/roomData.dart';
import '../event/last_one_leav_room.dart';
import '../event/room_have_news.dart';
import '../event/room_has_phone.dart';
import '../event/room_no_phone.dart';

import 'AudioPlayerUtil.dart';
import 'Constants.dart';

class SocketHelper{

  static int reconnection = 0;

  static WebSocketChannel socketChannel;

  static var myContext;
  static var joinRoomCallBack; // 加入房间失败回调
  static var saveSetTypewrite;  // 保存打字设置状态
  static var saveIsClosedWheat;  // 保存是否关闭麦克风
  static var matchIsOkCallBack;   // 快速匹配是否成功回调
  static var matchCancelCallBack;  // 取消快速匹配回调

  static bool socketIsCoonect = true; /// socket是否掉线

  static bool is_leave_room = false;  /// 是否离开房间
  static int leave_room_no;

  static bool call_phone = false;

  /// WebSocket连接
  static Future initWebSocketChannel() async {
    socketChannel = IOWebSocketChannel.connect('wss://${Constants.gateway}');
    //用户-认证
    socketLogin();
    try {
      socketChannel.stream.listen(
        onData,
        onDone: () {

          toast("websocket断开连接");
          socketIsCoonect = false;
  
          //断线后尝试重连
          SharedPreferences.getInstance().then((sp){
            String loginToken = sp.getString("loginToken");
            if (loginToken != null && loginToken != "" && Constants.connected){
              toast("websocket开启重连");
              if (reconnection >= 7){
                reconnection = 0;
                // sp.setString('loginToken', null);
                // sp.setString('userInfo', null);
                // sp.setString('gateway', null);
                SocketHelper.closeChannel();

                FloatWindow.instance.close();
                AudioPlayerUtil.instance.voiceCallPlayStop();
                Constants.eventBus.fire(ReloginEvent());
                return;
              }
              reconnection++;
              initWebSocketChannel();
            }
          });
        },
        onError: (error) {
          toast("webSocket出错");
        },
      );
    } catch (e) {
      toast("websocket异常");
    }

    if (Platform.isAndroid){
      HeartBeatPlugin.instance.start();
    } else if (Platform.isIOS){
      heartbeatIOS();
    } else {
      heartbeatIOS();
    }
  }

  static Future heartbeatIOS() async {
    while(true){
      await Future.delayed(Duration(seconds: 10), (){
        Map data = {
          "command_id": 100003,
        };
        if (socketChannel != null){
          socketChannel.sink.add(json.encode(data));
        }
      });
    }
  }

  static void heartbeat(){
    Map data = {
      "command_id": 100003,
    };
    if (socketChannel != null){
      socketChannel.sink.add(json.encode(data));
    }
  }

  //应用切换到后台 通知
  static Future sendOffLineMsg(int channelID
      , String channelName,String content) async {
    if (Constants.appState == AppLifecycleState.paused){
      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
          'nn_channel', 'nn_channel_name', 'nn_channel_description',
          importance: Importance.Max, priority: Priority.High);
      //IOS的通知配置
      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
      var platformChannelSpecifics = new NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      //显示通知，其中 0 代表通知的 id，用于区分通知。
      await flutterLocalNotificationsPlugin.show(
          channelID, channelName, content, platformChannelSpecifics,
          payload: 'message');
    }
  }

  ///socket监听
  static Future onData(event) async {
    print("webscoket 监听信息 = " + event.toString());

    Map result = jsonDecode(event);
    switch(result["command_id"]){
      case 100001:
        if(result["code"] != 0){
          toast("登陆信息失效，请重新登录！");
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('loginToken', null);
          prefs.setString('userInfo', null);
          prefs.setString('gateway', null);
          SocketHelper.closeChannel();
          Constants.eventBus.fire(ReloginEvent());
          AudioPlayerUtil.instance.voiceCallPlayStop();
          FloatWindow.instance.close();
        }
        break;
      case 100003:
        
        if(!socketIsCoonect) {
          socketIsCoonect = true;
          Constants.eventBus.fire(SocketIsBroken(
            isConnect: true
          ));
          
          if(is_leave_room) {  /// 如果离开房间的话就要发送离开房间广播
            goOutRoom(leave_room_no, Constants.roomContext);
          }
        }
        break;
      case 100014:
        if (result["data"] != null &&
            result["data"]["last_login_ip"] != result["data"]["current_login_ip"]){
          SocketHelper.closeChannel();
          toast("账号在另一台移动设备登录！");
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('loginToken', null);
          prefs.setString('userInfo', null);
          prefs.setString('gateway', null);
          Constants.eventBus.fire(ReloginEvent());
          AudioPlayerUtil.instance.voiceCallPlayStop();
          FloatWindow.instance.close();
        }
        break;
      case 300001: //单聊消息
        if (result["message_type"] == 1){ //消息回执
          Constants.eventBus.fire(UpdateChatMessageEvent(null));
          return;
        }
        Map data = result["data"];

//        if (Constants.appState == AppLifecycleState.paused){
//          var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
//              'nn_channel', 'nn_channel_name', 'nn_channel_description',
//              importance: Importance.Max, priority: Priority.High);
//          //IOS的通知配置
//          var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
//          var platformChannelSpecifics = new NotificationDetails(
//              androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//          //显示通知，其中 0 代表通知的 id，用于区分通知。
//          await flutterLocalNotificationsPlugin.show(
//              data["from_user"]["nn_id"], data["from_user"]["nickname"],
//              MessageType.getContentByMessageType(data["message_type"],
//                  data["content"]), platformChannelSpecifics,
//              payload: 'message');
//        }

        await sendOffLineMsg(data["from_user"]["nn_id"], data["from_user"]["nickname"],
            MessageType.getContentByMessageType(data["message_type"], data["content"]));

        //是否正在和websocket来源聊天
        bool isChating = false;
        if (Constants.isOnChatScreen && data["message_type"] == 4 &&
            (Constants.curChatUserId == data["from_user"]["nn_id"] || Constants.curChatUserId == data["to_user"]["nn_id"])){
          isChating = true;
        } else if (Constants.isOnChatScreen && Constants.curChatUserId == data["from_user"]["nn_id"]){
          isChating = true;
        }

        if (isChating){
          MessageItemEntity messageItem = new MessageItemEntity();
          messageItem.fromId = data["from_user"]["nn_id"];
          messageItem.toId = data["to_user"]["nn_id"];
          messageItem.messageType = data["message_type"];
          messageItem.content = data["content"];
          messageItem.msgId = data["msg_id"];
          messageItem.timestamp = data["timestamp"];
          if (data["extra"] != null){
            messageItem.extra = ExtraData(voiceDuration: data["extra"]["voice_duration"],
              callStatus: data["extra"]["call_status"],
              callDuration: data["extra"]["call_duration"],
              imageWidth: data["extra"]["image_width"],
              imageHeight: data["extra"]["image_height"],
            );
          }
          messageItem.isRead = false;
          Constants.eventBus.fire(UpdateChatMessageEvent(messageItem));
        } else {
          //1文字	 2图片	3录音	4语音通话	5系统消息	99自定义消息（如：nn://room/enter?id=639712&title=飞机票）
          ListMessageEntity listMessageEntity = ListMessageEntity();
          listMessageEntity.messageCategory = MessageCategory.chat;
          listMessageEntity.timestamp = data["timestamp"];
          listMessageEntity.messageType = data["message_type"];
          listMessageEntity.sendType = SendType.SEND_SUCCESS;
          listMessageEntity.isFriend = data["is_friend"];
          if (data["message_type"] == 5){
            if (data["from_user"]["nn_id"] == Constants.userInfo.nnId){
              listMessageEntity.nnId = data["to_user"]["nn_id"];
              listMessageEntity.avatar = data["to_user"]["avatar"];
              listMessageEntity.nickname = data["to_user"]["nickname"];
              listMessageEntity.gender = data["to_user"]["gender"];
            } else {
              listMessageEntity.nnId = data["from_user"]["nn_id"];
              listMessageEntity.avatar = data["from_user"]["avatar"];
              listMessageEntity.nickname = data["from_user"]["nickname"];
              listMessageEntity.gender = data["from_user"]["gender"];
            }
            listMessageEntity.content = MessageType.getContentByMessageType(listMessageEntity.messageType, data["content"]);
            Constants.eventBus.fire(UpdateMessageListEvent(type: 1, nnId: listMessageEntity.nnId, content: listMessageEntity.content,
                timestamp: data["timestamp"], listMessage: listMessageEntity, messageType: data["message_type"]
            ));
            Constants.eventBus.fire(UpdateUnreadEvent(num: -1));
          } else {
              listMessageEntity.content = MessageType.getContentByMessageType(listMessageEntity.messageType, data["content"]);
              //发起语音通话后，缩放成悬浮窗并退出聊天页面后，收到消息
              if (data["message_type"] == 4 && data["from_user"]["nn_id"] == Constants.userInfo.nnId){
                listMessageEntity.nnId = data["to_user"]["nn_id"];
                listMessageEntity.avatar = data["to_user"]["avatar"];
                listMessageEntity.nickname = data["to_user"]["nickname"];
                listMessageEntity.gender = data["to_user"]["gender"];
                Constants.eventBus.fire(UpdateMessageListEvent(type: 0, nnId: data["to_user"]["nn_id"], content: listMessageEntity.content,
                    timestamp: data["timestamp"], listMessage: listMessageEntity
                ));
              } else {
                listMessageEntity.nnId = data["from_user"]["nn_id"];
                listMessageEntity.avatar = data["from_user"]["avatar"];
                listMessageEntity.nickname = data["from_user"]["nickname"];
                listMessageEntity.gender = data["from_user"]["gender"];
                Constants.eventBus.fire(UpdateMessageListEvent(type: 1, nnId: data["from_user"]["nn_id"], content: listMessageEntity.content,
                    timestamp: data["timestamp"], listMessage: listMessageEntity
                ));
                Constants.eventBus.fire(UpdateUnreadEvent(num: -1));
              }
          }
        }
        break;
      case 300003: //语音通话
      if (result["code"] == 0){
        if(result["message_type"] == 1) {
          call_phone = !call_phone;
          if(!call_phone) {
            Constants.eventBus.fire(RoomNoPhone(
              isClose: true,
            ));
            Provide.value<RoomData>(Constants.roomContext).changeIsOnLine(false);
          }
        }
        
        if (result["data"] != null && result["data"]["friend"] != null){
          Map data = result["data"]["friend"];
          Constants.eventBus.fire(VoiceCallStateEvent(nnId: data["nn_id"], avatar: data["avatar"], nickName: data["nickname"],
              type: result["data"]["status"]));
        }
        Constants.isSendError = false;
      } else {
        Constants.isSendError = true;
        Constants.eventBus.fire(VoiceCallStateEvent(type: -1, errorMessage: result["msg"]));
      }

      if (result["data"] != null){

        if (result["data"]["status"] == VoiceStatusType.SEND_REQUEST){
          print('cccccccccccccccccccccccccc');
          Provide.value<RoomData>(Constants.roomContext).changeIsOnLine(true);
          Constants.eventBus.fire(RoomHasPhone(
            isHave: true,
          ));
          AudioPlayerUtil.instance.voiceCallPlay();

          await sendOffLineMsg(result["data"]["friend"]["nn_id"], result["data"]["friend"]["nickname"], "正在呼叫您");

        } else if(result["data"]["status"] == VoiceStatusType.CANCAL ||
            result["data"]["status"] == VoiceStatusType.OK ||
            result["data"]["status"] == VoiceStatusType.REFUSED ||
            result["data"]["status"] == VoiceStatusType.HANDLE_ON_OTHER ||
            result["data"]["status"] == VoiceStatusType.HANG_UP ||
            result["data"]["status"] == VoiceStatusType.NETWORK_ERROR ||
            result["data"]["status"] == VoiceStatusType.REPONSE_TIME_OUT){
          AudioPlayerUtil.instance.voiceCallPlayStop();
          Constants.time = 0;
          if (Constants.timer != null){
            Constants.timer.cancel();
          }

          if(Constants.isOnCalling){
            Navigator.of(Constants.mainContext);
          }
        }

        if (result["data"]["status"] == VoiceStatusType.CANCAL ||
            result["data"]["status"] == VoiceStatusType.REFUSED ||
            result["data"]["status"] == VoiceStatusType.HANDLE_ON_OTHER ||
            result["data"]["status"] == VoiceStatusType.HANG_UP ||
            result["data"]["status"] == VoiceStatusType.NETWORK_ERROR ||
            result["data"]["status"] == VoiceStatusType.REPONSE_TIME_OUT){
          AgoraRtcEngine.leaveChannel();
          FloatWindow.instance.close();
          FloatWindow.userNnId = null;
          print('|||||||||||||||||||||||||||||||||||||');
          Constants.eventBus.fire(RoomNoPhone(
            isClose: true,
          ));
        }

        if (result["data"]["status"] == VoiceStatusType.OK){
          FloatWindow.instance.startVoiceCall();
        }

        //TODO 语音通话 发送消息 界面处理
        if (Constants.isOnChatScreen && Constants.curChatUserId == result["data"]["friend"]["nn_id"]){

        } else {

        }
      }



        break;
      case 300002: //好友申请---消息助手
        if ((result["message_type"] == 1)){
          return;
        }
        Map data = result["data"];

        if (data["status"] != null && data["status"] == 2){
          Constants.eventBus.fire(AddFriendEvent());

          //好友列表更新
          Constants.eventBus.fire(AddFriendSuccessEvent());

          //更新消息助手
          Constants.eventBus.fire(UpdateMessageHelperEvevt(useId: data["from_user"]["nn_id"],
              avatar: data["from_user"]["avatar"],
              status: data["status"],
              nickName: data["from_user"]["nickname"]));
          return;
        }

        if (data["from_user"] != null && data["status"] != null){
          if(data["status"] == 1){
            //更新消息助手
            Constants.eventBus.fire(UpdateMessageHelperEvevt(useId: data["from_user"]["nn_id"],
                avatar: data["from_user"]["avatar"],
                status: data["status"],
                nickName: data["from_user"]["nickname"]));
            //更新未读消息数目
            Constants.eventBus.fire(UpdateUnreadEvent(num: -1));
          }
        }
        break;
      case 300006:
        //删除最近联系人

        break;
      case 300003:
        //删除好友

        break;
      case 300100:
        //修改群聊名称
        if (result["data"] != null){
          Constants.eventBus.fire(UpdateGroupEvent(groupNo: result["data"]["groups_no"], groupName: result["data"]["groups_name"], type: UpdateGroupType.updateGroupName));
        }
        break;
      case 300101:
        //被别人拉入群
        if (result["data"] != null){
          GroupEntity groupEntity = GroupEntity();
          groupEntity.groupsNo = result["data"]["groups_no"];
          groupEntity.groupsName = result["data"]["groups_name"];
          groupEntity.avatar = result["data"]["avatar"];
          Constants.eventBus.fire(UpdateGroupEvent(groupNo: result["data"]["groups_no"],
              groupName: result["data"]["groups_name"], groupEntity: groupEntity, type: UpdateGroupType.addGroup));
        }
        break;
      case 300106:
        //群聊消息
        if (result["message_type"] == 1){ //消息回执
          Constants.eventBus.fire(UpdateChatMessageEvent(null));
          return;
        }

        Map data = result["data"];

        await sendOffLineMsg(data["groups_no"], data["groups_name"], MessageType.getContentByMessageType(data["message_type"], data["content"]));

        if (Constants.isOnGroupChatScreen && Constants.curChatGroupNo == data["groups_no"]){
          GroupMessageItemEntity messageItem = new GroupMessageItemEntity();
          messageItem.groupNo = data["groups_no"];
          if (data["from_user"] != null){
            messageItem.fromNnid = data["from_user"]["nn_id"];
            messageItem.fromNickname = data["from_user"]["nickname"];
            messageItem.fromAvatar = data["from_user"]["avatar"];
          }
          messageItem.messageType = data["message_type"];
          messageItem.content = data["content"];
          messageItem.msgId = data["msg_id"];
          messageItem.timestamp = data["timestamp"];
          if (data["extra"] != null){
            messageItem.extra = ExtraData(voiceDuration: data["extra"]["voice_duration"],
              callStatus: data["extra"]["call_status"],
              callDuration: data["extra"]["call_duration"],
              imageWidth: data["extra"]["image_width"],
              imageHeight: data["extra"]["image_height"],
            );
          }
          messageItem.isRead = false;
          Constants.eventBus.fire(UpdateGroupChatMessageEvent(messageItem));
        } else {
          //1文字	 2图片	3录音	4语音通话	5系统消息	99自定义消息（如：nn://room/enter?id=639712&title=飞机票）
          ListMessageEntity listMessageEntity = ListMessageEntity();
          listMessageEntity.messageCategory = MessageCategory.groupChat;
          listMessageEntity.timestamp = data["timestamp"];
          listMessageEntity.messageType = data["message_type"];
          listMessageEntity.sendType = SendType.SEND_SUCCESS;
          listMessageEntity.groupsNo = data["groups_no"];
          listMessageEntity.avatar =  data["groups_avatar"];
          listMessageEntity.groupsName =  data["groups_name"];
          listMessageEntity.content = MessageType.getContentByMessageType(listMessageEntity.messageType, data["content"]);

          Constants.eventBus.fire(UpdateMessageListEvent(type: 1,groupNo: data["groups_no"],content: data["content"],
              timestamp: data["timestamp"],
              listMessage: listMessageEntity));
          Constants.eventBus.fire(UpdateUnreadEvent(num: -1));

          //TODO xx加入群聊  群聊中间的灰色小系统消息
          if (data["message_type"] == 5){

          }
        }
        break;
      case 400100:
        //系统公告发布
        if (result["data"] != null && result["data"]["title"] != null){
          Constants.eventBus.fire(SystemNoticeEvent(title: result["data"]["title"]));

          Constants.eventBus.fire(UpdateUnreadEvent(num: -1));
        }
        break;

      case 400101:
        //系统公告撤回

        break;
      case 400102:
        //新建群
        if (result["data"] != null){
          Map data = result["data"];

          GroupEntity groupEntity = GroupEntity();
          groupEntity.groupsNo = data["groups_no"];
          groupEntity.groupsName = data["groups_name"];
          groupEntity.avatar = data["avatar"];
          Constants.eventBus.fire(UpdateGroupEvent(groupNo: data["groups_no"],
              groupName: data["groups_name"], groupEntity: groupEntity, type: UpdateGroupType.addGroup));

          ListMessageEntity listMessageEntity = ListMessageEntity();
          listMessageEntity.messageCategory = MessageCategory.groupChat;
          listMessageEntity.timestamp = data["timestamp"];
          listMessageEntity.sendType = SendType.SEND_SUCCESS;
          listMessageEntity.groupsNo = data["groups_no"];
          listMessageEntity.avatar =  data["avatar"];
          listMessageEntity.groupsName =  data["groups_name"];
          listMessageEntity.content = MessageType.getContentByMessageType(listMessageEntity.messageType, data["content"]);

          Constants.eventBus.fire(UpdateMessageListEvent(type: 1,groupNo: data["groups_no"],content: data["content"],
              timestamp: data["timestamp"],
              listMessage: listMessageEntity));
        }
        break;
      case 400103:
        if(result['code'] == 0) {
          Constants.eventBus.fire(AddNewRoom(
            room_no: result['data']['room_no'], name: result['data']['name'],
            game_name: result['data']["game_name"],
            game_id: result['data']["game_id"],
            area_name: result['data']["area_name"],
            online_number: result['data']["online_number"],
            avatar: result['data']["avatar"],
            is_match: result['data']["is_match"],
            is_full: result['data']["is_full"],
            level_name: result['data']["level_name"],
          ));
        }
        break;
      case 500000:
        if(result['code'] == 0) {
          if(result['message_type'] == 1) {
            is_leave_room = false;
            leave_room_no = null;
            joinRoomCallBack(true, '成功');
            result['data']['user_list'].forEach((res){
              res['isTypeWrite'] = res['is_word'];
              res['isClosedWheat'] = res['is_mic'];
              res['is_drop_line'] = false;
            });
            Provide.value<StoreData>(myContext).setRoomUserList(result['data']['user_list']);
            Provide.value<StoreData>(myContext).setRoomInfo(result['data']['room']);
            Provide.value<StoreData>(myContext).setRoomIsOpen(result['data']['room']['is_match']);
            var data = {
              'command_id': 500000,
              'name': Provide.value<StoreData>(myContext).userInfo['nickname'],
              'content': result['data']['content'],
              'nn_id': Provide.value<StoreData>(myContext).userInfo['nn_id']
            };
            Provide.value<StoreData>(myContext).saveChatList(data);
          } else {
            var data = {
              'command_id': 500000,
              'name': result['data']['nickname'],
              'content': result['data']['nickname'],
              'nn_id': result['data']['nn_id']
            };
            var a = result['data'];
            a['is_admin'] = false;
            a['isTypeWrite'] = result['data']['is_word'];
            a['isClosedWheat'] = result['data']['is_mic'];
            a['is_drop_line'] = false;

            int isOutRoom = null;  /// 判断新进来的人是否在现在的房间列表里边（非正常退出的时候，房间人员没有删除）
            for(int i = 0; i < Provide.value<StoreData>(Constants.roomContext).room_user_list.length; i += 1) {
              if(Provide.value<StoreData>(Constants.roomContext).room_user_list[i]['nn_id'] == result['data']['nn_id']) {
                isOutRoom = i;
              }
            }
            if(isOutRoom != null) {
              var list = [];
              list.addAll(Provide.value<StoreData>(Constants.roomContext).room_user_list);
              list.fillRange(isOutRoom, a);
              Provide.value<StoreData>(myContext).setRoomUserList(list);
            } else {
              Provide.value<StoreData>(Constants.roomContext).changeRoomUserList(a);
            }
            Provide.value<StoreData>(Constants.roomContext).saveChatList(data);
            Provide.value<StoreData>(Constants.roomContext).setJumpBottom(true);
          }
        } else {
          joinRoomCallBack(false, result['msg']);
        }
        break;
      case 500001:
        if(result['code'] == 0) {
          if(result['message_type'] == 1) {
            // Provide.value<RoomData>(Constants.roomContext).changeIsLastOne(result['data']);
            print('llllllllllllllllllllllll$result');
            Constants.eventBus.fire(LastOneLeavRoom(
              isLast: result['data']['is_last'],
              roomNo: result['data']['room_no'],
            ));
          }
          if(result['message_type'] == 2) {
            var copyList = [];
            var myData = Provide.value<StoreData>(Constants.roomContext).room_user_list;
            for(int i = 0; i < myData.length; i += 1) {
              copyList.add(myData[i]);
            }
            for(int i = 0; i < copyList.length; i += 1) {
              if(copyList[i]['nn_id'] == result['data']['quit_user']['nn_id']) {
                copyList.removeAt(i);
              }

              if(result['data']['new_admin_user'] != null) {
                if(result['data']['new_admin_user']['nn_id'] == copyList[i]['nn_id']) {
                  copyList[i]['is_admin'] = true;
                  copyList[i]['isTypeWrite'] = true;
                  copyList[i]['isClosedWheat'] = true;
                }
              }
            }
            

            Provide.value<StoreData>(Constants.roomContext).setRoomUserList(copyList);
            Provide.value<StoreData>(Constants.roomContext).setJumpBottom(true);
            print('zzzzzzzzzzzzzzzzzz');
          }
        }
        break;
      case 500002:
        if(result['code'] == 0) {  //聊天消息R
          if(result['message_type'] == 1) {
            if(result['data']['message_type'] == 2) {
              toast('图片发送成功!');
            }
          }
          if(result['message_type'] == 2) {
            var data = null;
            data = {
              'command_id': 500002,
              'message_type': result['data']['message_type'],
              'name': result['data']['from_user']['nickname'],
              'content': result['data']['content'],
              'nn_id': result['data']['from_user']['nn_id']
            };
            Provide.value<StoreData>(Constants.roomContext).saveChatList(data);
            Provide.value<StoreData>(Constants.roomContext).setJumpBottom(true);
            Constants.eventBus.fire(RoomHaveNews(
              isHave: true,
            ));
          }

        }
        break;
      case 500003:
        if(result['code'] == 0) {
          if(result['message_type'] == 2) {
            Provide.value<StoreData>(myContext).setRoomIsOpen(result['data']['is_match']);
          }
        }
        break;
      case 500004:   /// 设置打字
        if(result['code'] == 0) {
          if(result['message_type'] == 2) {
            var copyData = [];
            for(int i = 0; i < Provide.value<StoreData>(myContext).room_user_list.length; i += 1) {
              copyData.add(Provide.value<StoreData>(myContext).room_user_list[i]);
            }
            copyData.forEach((res){
              if(res['nn_id'] == result['data']['nn_id']) {
                res['isTypeWrite'] = !result['data']['forbid'];
              }
            });
            Provide.value<StoreData>(myContext).setRoomUserList(copyData);
          }
        }
        break;
      case 500005:   /// 是否关闭麦克风
        if(result['code'] == 0) {
          if(result['message_type'] == 2) {
            var copyData = [];
            for(int i = 0; i < Provide.value<StoreData>(myContext).room_user_list.length; i += 1) {
              copyData.add(Provide.value<StoreData>(myContext).room_user_list[i]);
            }
            copyData.forEach((res){
              if(res['nn_id'] == result['data']['nn_id']) {
                res['isClosedWheat'] = !result['data']['forbid'];
              }
            });
            Provide.value<StoreData>(myContext).setRoomUserList(copyData);
          }
        }
        break;
      case 500006:   /// 踢出房间
        if(result['code'] == 0) {
          if(result['message_type'] == 2) {
            var myData = Provide.value<StoreData>(myContext).room_user_list;
            for(int i = 0; i < myData.length; i += 1) {
              if(myData[i]['nn_id'] == result['data']['nn_id']) {
                myData.removeAt(i);
              }
            }
            if(result['data']['nn_id'] == Provide.value<StoreData>(myContext).userInfo['nn_id']) {
              Provide.value<StoreData>(myContext).setIsOut(true);
              Provide.value<StoreData>(myContext).saveHomeRoomNo(null);   /// 如果收起房间回到首页，这个时候如果被房主踢出，悬浮框去除
              toast('您已被房主请出房间！');
            }
            Provide.value<StoreData>(myContext).setRoomUserList(myData);
          }
        }
        break;
      case 500008: // 开始快速匹配
        if(result['code'] == 0) {
          matchIsOkCallBack(true, result['data']['room_no']);
        } else {
          matchIsOkCallBack(false, result['msg']);
        }
        break;
      case 500009: // 取消快速匹配
        if(result['code'] == 0) {
          matchCancelCallBack(true, '取消成功');
        } else {
          matchCancelCallBack(false, result['msg']);
        }
        break;
      case 500010: // 用户掉线
        if(result['code'] == 0) {
          var copyList = [];
          var myData = Provide.value<StoreData>(myContext).room_user_list;
          for(int i = 0; i < myData.length; i += 1) {
            copyList.add(myData[i]);
          }

          for(int i = 0; i < copyList.length; i += 1) {
            if(copyList[i]['nn_id'] == result['data']['drop_line_user']['nn_id']) {
              copyList[i]['is_drop_line'] = true; /// true为掉线
              copyList[i]['is_admin'] = false;
            }

            if(result['data']['new_admin_user'] != null) {/// 如果有值，那么就是说有新房主产生
              if(result['data']['new_admin_user']['nn_id'] == copyList[i]['nn_id']) {
                copyList[i]['is_admin'] = true;
                copyList[i]['isTypeWrite'] = true;
                copyList[i]['isClosedWheat'] = true;
              }
              
            }
          }
          Provide.value<StoreData>(myContext).setRoomUserList(copyList);
          Provide.value<StoreData>(myContext).setJumpBottom(true);
        }
        break;
      case 500011:  /// 房间名称更改
        if(result['code'] == 0) {
          if(result['message_type'] == 2) {
            print('222222222222222222222222222222');
            var info = Provide.value<StoreData>(Constants.roomContext).room_info;
            info['room_name'] = result['data']['name'];
            Provide.value<StoreData>(Constants.roomContext).setRoomInfo(info);
          }
        }
        break;
      case 500012:
        if(result['code'] == 0) {
          if(result['message_type'] == 1) {   //// 自己重连成功，更新人员列表
            print('bbbbbbbbbbbbbb');
            if(!is_leave_room) {
              result['data']['user_list'].forEach((res){
                res['isTypeWrite'] = res['is_word'];
                res['isClosedWheat'] = res['is_mic'];
                res['is_drop_line'] = false;
              });
              Provide.value<StoreData>(myContext).setRoomUserList(result['data']['user_list']);
              Provide.value<StoreData>(myContext).setRoomInfo(result['data']['room']);
            }
          }
          if(result['message_type'] == 2) {  /// 自己受到别人重连成功提示
            var copyList = [];
            var myData = Provide.value<StoreData>(myContext).room_user_list;
            for(int i = 0; i < myData.length; i += 1) {
              copyList.add(myData[i]);
            }

            for(int i = 0; i < copyList.length; i += 1) {
              if(copyList[i]['nn_id'] == result['data']['nn_id']) {
                copyList[i]['is_drop_line'] = false; /// true为掉线
              }
            }
            Provide.value<StoreData>(myContext).setRoomUserList(copyList);
          }
        }
        break;
    }
  }

  ///登录认证
  static void socketLogin(){
    Map data = {
      "version": 1,
      "command_id": 100001,
      "compression_type": 0,
      "message_type": 0,
      "data": {
        "token": Constants.token,
        "login_type":0
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  ///删除并退出群聊
  static void deleteAndExit(int groupNo){
    Map data = {
      "command_id": 300103,
      "data": {
        "groups_no": groupNo
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  ///修改群聊名称
  static void updateGroupName(int groupNo, String groupName){
    Map data = {
      "command_id": 300100,
      "data": {
        "groups_no": groupNo,
        "groups_name": groupName
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  ///删除群聊成员
  static void removeGroupMembers(int groupNo, List<int> ids){
    Map data = {
      "command_id": 300102,
      "data": {
        "groups_no": groupNo,
        "nn_id": ids
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  ///添加群聊成员
  static void addGroupMembers(int groupNo, List<int> ids){
    Map data = {
      "command_id": 300101,
      "data": {
        "groups_no": groupNo,
        "nn_id": ids
      }
    };
    print("webscoket 执行任务,参数: ${json.encode(data)}");
    socketChannel.sink.add(json.encode(data));
  }

  ///好友关系处理
  static void friendOperation(int type, int nnId){
    Map data = {
      "command_id": 300002,
      "data": {
        "friend_id": nnId,
        "status": type,
      }
    };
    print("好友关系处理 $data");
    socketChannel.sink.add(json.encode(data));
  }

  ///添加好友
  ///status : 1 添加好友  2 同意  3 拒绝  4 忽略
  ///friend_from :1 通过搜索添加   2 通过频道添加
  static void addFriend(int nnId, int from, String validationMsg, int status){
    Map data = {
      "command_id": 300002,
      "data": {
        "friend_id": nnId,
        "status": status,
        "validation_msg": validationMsg,
        "friend_from": from
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  ///删除最近联系人
  static void deleteContact(int nnId){
    Map data = {
      "command_id": 300006,
      "data": {
        "contact_id": nnId
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  ///删除最近联系人
  static void deleteGroupContact(int groupNo){
    Map data = {
      "command_id": 300109,
      "data": {
        "groups_no": groupNo
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  ///删除好友
  static void deleteFriend(int nnId){
    Map data = {
      "command_id": 300005,
      "data": {
        "friend_id": nnId
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  ///发送消息
  static void sendMessage(int nnId, String content, int messageType, int timestamp, {int voiceDuration}){
    Map data = {
      "command_id": 300001,
      "sequence_id": timestamp,
      "data": {
        "to_id": nnId,
        "message_type": messageType,
        "content": content,
        "voice_duration": voiceDuration
      }
    };
    print("发送消息：$data");
    socketChannel.sink.add(json.encode(data));
  }

  ///发送群聊消息
  static void sendGroupMessage(int groupNo, String content, int messageType, int timestamp, {int voiceDuration}){
    Map data = {
      "command_id": 300106,
      "sequence_id": timestamp,
      "data": {
        "groups_no": groupNo,
        "message_type": messageType,
        "content": content,
        "voice_duration": voiceDuration,
        "to_id": null //被@nn号 暂时未做
      }
    };
    print("发送消息：$data");
    socketChannel.sink.add(json.encode(data));
  }

  ///标记消息已读
  static void markMessageRead(int friendId){
    Map data = {
      "command_id": 100021,
      "compression_type": 0,
      "data": {
        "friend_id": friendId,
      }
    };
    socketChannel.sink.add(json.encode(data));

    //更改主页未读数
    Constants.eventBus.fire(UpdateUnreadEvent());
  }

  ///发送语音通话
  /// status_type ; 1发起请求，2对方未在线，3不是好友关系，4对方忙碌中(正在使用语音通话)， 5主动取消语音通话，
  ///               6接收者同意接听，7接收者拒绝，8已在其他端处理请求，9挂断，10网络异常中断，11超时无应答
  static void sendVoiceCall(int friendId, int status_type){
    Map data = {
      "command_id": 300003,
      "data": {
        "friend_id": friendId,
        "status": status_type
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  ////////////////   房间内容
  ///
  ///
  ///////////////
  static void joinRoom(int room_no, int type, context, callback) {     /// 进入房间
    print('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa${room_no}    ${type}');
    myContext = context;
    joinRoomCallBack = callback;
    Map data={
      "command_id": 500000,
      "data": {
          "room_no": room_no,
          "entry_mode": type
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  static void goOutRoom(int room_no, context) {     /// 退出房间
    print('6666666666666666666666666666666666666666666${socketIsCoonect}');
    is_leave_room = true;
    leave_room_no = room_no;
    myContext = context;
    Map data={
      "command_id": 500001,
      "data": {
          "room_no": room_no
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  static void sendRoomMessage(int room_no, int message_type, content,  context) {     /// 发送消息    注意消息类型
    myContext = context;
    Map data={
      "command_id": 500002,
      "data": {
          "room_no": room_no,
          "message_type": message_type,
          "content": content,
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  static void matchOnOff(int room_no, bool forbid,  context) {     /// 发送消息
    myContext = context;
    Map data={
      "command_id": 500003,
      "data": {
          "room_no": room_no,
          "forbid": forbid
      }
    };
    socketChannel.sink.add(json.encode(data));
  }


  static void isClosedWheat(int room_no, int nn_id, bool forbid,  context) {     /// 是否关闭麦克风
    myContext = context;
    saveIsClosedWheat = forbid;
    print('jjjjjjjjjjjjjj$forbid');
    Map data={
      "command_id": 500005,
      "data": {
          "room_no": room_no,
          "nn_id": nn_id,
          "forbid": !forbid
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  static void setTypewrite(int room_no, int nn_id, bool forbid,  context) {     /// 打字设置
    myContext = context;
    saveSetTypewrite = forbid;
    Map data={
      "command_id": 500004,
      "data": {
          "room_no": room_no,
          "nn_id": nn_id,
          "forbid": !forbid
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  static void kickedOutRoom(int room_no, int nn_id, bool forbid,  context) {     /// 踢出房间
    myContext = context;
    Map data={
      "command_id": 500006,
      "data": {
          "room_no": room_no,
          "nn_id": nn_id,
          "forbid": forbid
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  static void matchStart(int game_id, int area_id, int level_id, int mode_id, context, callBack) {     /// 开始匹配
    myContext = context;
    matchIsOkCallBack = callBack;
    Map data={
      "command_id": 500008,
      "data": {
        "game_id": game_id,
        "area_id": area_id,
        "level_id": level_id,
        "mode_id": mode_id
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  static void matchCancel(context, myData, callback) {     /// 取消匹配
    
    myContext = context;
    matchCancelCallBack = callback;
    Map data={
      "command_id": 500009,
      'data': {
        'game_id': myData['game_id'],
        'area_id': myData['area_id'],
        'level_id': myData['level_id'],
        'mode_id': myData['mode_id'],
      }
    };
    print('cccccccccccccccccccccccc$data');
    socketChannel.sink.add(json.encode(data));
  }

  static void changeRoomName(no, name, context) {
    myContext = context;
    Map data={
      "command_id": 500011,
      "data": {
        "room_no": no,
        "name": name
      }
    };
    socketChannel.sink.add(json.encode(data));
  }

  static void socketConnectAgain(context) {
    myContext = context;
    Map data={
      "command_id": 500012,
    };
    socketChannel.sink.add(json.encode(data));
  }

  ///关闭socket
  static void closeChannel(){
    if (socketChannel != null){
      reconnection = 0;
      socketChannel.sink.close();
      socketChannel.sink.done;
      socketChannel = null;
    }
  }
}