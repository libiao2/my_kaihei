class MessageItemEntity {
  int msgId; //消息id
  int fromId; //发送人NN号 / 群号
  int toId; //接受人NN号 / 群号
  int messageType; //消息类型 1文字 2图片 3语音 4语音通话 5系统消息 99自定义消息(形如nn://room/enter?id=639712&title=飞机票)
  String content; //消息内容
  int timestamp; //时间戳
  bool isRead; //是否已读
  ExtraData extra; //拓展信息 如录音时长;

  //本地使用字段
  int sequenceId; //确定消息的唯一字段，用来控制消息的发送状态，
  int sendType; //发送状态， 发送中/发送成功/发送失败

  MessageItemEntity(
      {this.content, this.timestamp, this.messageType, this.isRead, this.extra,
        this.fromId, this.msgId, this.toId, this.sendType, this.sequenceId});

  MessageItemEntity.fromJson(Map<String, dynamic> json) {
    msgId = json['msg_id'];
    fromId = json['from_id'];
    toId = json['to_id'];
    messageType = json['message_type'];
    content = json['content'];
    timestamp = json['timestamp'];
    isRead = json['is_read'] == 1?true:false;
    extra = json['extra'] != null?ExtraData.fromJson(json['extra']):null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg_id'] = this.msgId;
    data['from_id'] = this.fromId;
    data['to_id'] = this.toId;
    data['message_type'] = this.messageType;
    data['content'] = this.content;
    data['timestamp'] = this.timestamp;
    data['is_read'] = this.isRead;
    data['extra'] = this.extra == null?null:extra.toJson();
    return data;
  }

  @override
  String toString() {
    return 'MessageItemEntity{msgId: $msgId, fromId: $fromId, toId: $toId, messageType: $messageType, content: $content, timestamp: $timestamp, isRead: $isRead, extra: $extra, sequenceId: $sequenceId, sendType: $sendType}';
  }

}

class ExtraData {
  //录音时长
  int voiceDuration;

  //通话时长
  int callDuration;

  //通话状态
  int callStatus;

  //图片宽度
  int imageWidth;

  //图片高度
  int imageHeight;

  ExtraData({this.voiceDuration, this.callDuration, this.callStatus, this.imageWidth, this.imageHeight});

  ExtraData.fromJson(Map<String, dynamic> json) {
    this.voiceDuration = json["voice_duration"];
    this.callDuration = json["call_duration"];
    this.callStatus = json["call_status"];
    this.imageWidth = json["image_width"];
    this.imageHeight = json["image_height"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["voice_duration"] = this.voiceDuration;
    data["call_duration"] = this.callDuration;
    data["call_status"] = this.callStatus;
    data["image_width"] = this.imageWidth;
    data["image_height"] = this.imageHeight;
    return data;
  }
}
