class FloatWindowEvent{
  int floatType;//0：语音通话    1：房间

  int nnId;

  int time;//通话时间

  int roomNo;//房间号

  String nickname;//用户昵称

  String avatar;//用户头像

  int voiceCallType;//通话状态   语音通话界面使用

  FloatWindowEvent({this.floatType, this.avatar, this.nickname, this.time, this.roomNo, this.nnId, this.voiceCallType});
}