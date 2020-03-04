class MessageType{
  static const int TEXT = 1;//文字
  static const int IMAGE = 2;//图片
  static const int RECORD = 3;//录音
  static const int VOICE_CALL = 4;//语音通话
  static const int SYSTEM = 5;//系统消息
  static const int SHARE_ROOM = 6;//系统消息
  static const int CUSTOM = 99  ;//自定义消息(形如nn://room/enter?id=639712&title=飞机票)

  static String getContentByMessageType(int type, String content){
    String result = content;
    switch(type){
      case MessageType.TEXT:
        result = content;
        break;
      case MessageType.IMAGE:
        result = "[图片]";
        break;
      case MessageType.RECORD:
        result = "[语音消息]";
        break;
      case MessageType.SHARE_ROOM:
        result = "[分享消息]";
        break;
      case MessageType.VOICE_CALL:
        result = "[语音通话]";
        break;
    }
    return result;
  }
}