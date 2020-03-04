class UpdateMessageHelperEvevt{
  int useId;
  String nickName;
  String avatar;
  int status;//1:申请  2：同意  3：拒绝  4：忽略   5：清空消息助手，变成空字符串
  UpdateMessageHelperEvevt({this.avatar, this.nickName, this.useId, this.status});
}