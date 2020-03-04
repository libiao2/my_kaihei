class GroupEvent{

  int groupNo;

  int type;

  GroupEvent({this.groupNo, this.type});
}

class GroupEventType{
  static const int deleteAndExitGroup = 0;
  static const int addGroup = 1;
  static const int clearGroupChat = 2;
}