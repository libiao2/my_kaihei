///1发起请求，2对方未在线，3不是好友关系，4对方忙碌中(正在使用语音通话)， 5主动取消语音通话，
/// 6接收者同意接听，7接收者拒绝，8已在其他端处理请求，9挂断，10网络异常中断，11超时无应答
///
class VoiceStatusType{
  ///发起请求
  static const int SEND_REQUEST = 1;//发送语音通话
  static const int NOT_ON_LINE = 2;//对方未在线
  static const int NOT_FRIEND = 3;//不是好友关系
  static const int BUSY = 4;//对方忙碌中(正在使用语音通话)
  static const int CANCAL = 5;//主动取消语音通话
  static const int OK = 6;//接收者同意接听
  static const int REFUSED = 7;//接收者拒绝
  static const int HANDLE_ON_OTHER = 8;//已在其他端处理请求
  static const int HANG_UP = 9;//挂断
  static const int NETWORK_ERROR = 10;//0网络异常中断
  static const int REPONSE_TIME_OUT = 11;//超时无应答
}