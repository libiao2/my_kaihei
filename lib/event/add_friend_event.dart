class AddFriendEvent{

  int type;

  String remark;

  int nnId;

  AddFriendEvent({this.type, this.remark, this.nnId});
}

class FriendInfoUpdateType{
  static const addFriend = 0;
  static const updateRemark = 1;
}