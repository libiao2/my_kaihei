import 'message_item_entity.dart';

class GroupMessageItemEntity {
  int msgId; //消息id
  int messageType; //消息类型 1文字 2图片 3语音 4语音通话 5系统消息 99自定义消息(形如nn://room/enter?id=639712&title=飞机票)
  String content; //消息内容
  int timestamp; //时间戳
  bool isRead; //是否已读
  ExtraData extra; //拓展信息 如录音时长;
  int fromNnid;
  int groupNo;
  String fromNickname;
  String fromAvatar;

  //本地使用字段
  int sequenceId; //确定消息的唯一字段，用来控制消息的发送状态，
  int sendType; //发送状态， 发送中/发送成功/发送失败

  GroupMessageItemEntity(
      {this.content, this.timestamp, this.messageType, this.isRead, this.extra,
        this.msgId, this.sendType, this.sequenceId, this.groupNo, this.fromAvatar, this.fromNickname, this.fromNnid});

  GroupMessageItemEntity.fromJson(Map<String, dynamic> json) {
    msgId = json['msg_id'];
    messageType = json['message_type'];
    content = json['content'];
    timestamp = json['timestamp'];
    groupNo = json['groups_no'];
    fromNnid = json['from_user'] != null?json['from_user']['nn_id']:null;
    fromAvatar = json['from_user'] != null?json['from_user']['avatar']:null;
    fromNickname = json['from_user'] != null?json['from_user']['nickname']:null;
    isRead = json['is_read'] == 1?true:false;
    extra = json['extra'] != null?ExtraData.fromJson(json['extra']):null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg_id'] = this.msgId;
    data['message_type'] = this.messageType;
    data['content'] = this.content;
    data['timestamp'] = this.timestamp;
    data['groups_no'] = this.groupNo;
    data['nn_id'] = this.fromNnid;
    data['avatar'] = this.fromAvatar;
    data['nickname'] = this.fromNickname;
    data['is_read'] = this.isRead == true?1:0;
    data['extra'] = this.extra == null?null:extra.toJson();
    return data;
  }

  @override
  String toString() {
    return 'MessageItemEntity{msgId: $msgId, messageType: $messageType, content: $content, timestamp: $timestamp, isRead: $isRead, extra: $extra, fromNnid: $fromNnid, groupNo: $groupNo, fromNickname: $fromNickname, fromAvatar: $fromAvatar, sequenceId: $sequenceId, sendType: $sendType}';
  }

}
