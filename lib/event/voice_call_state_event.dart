

class VoiceCallStateEvent{

  int type;

  int nnId;

  String nickName;

  String avatar;

  String errorMessage;

  VoiceCallStateEvent({this.type, this.nnId, this.avatar, this.nickName, this.errorMessage});
}