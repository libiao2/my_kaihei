import 'package:premades_nn/model/group_member_entity.dart';

class GroupSettingEvent{

  int type;

  List<GroupMemberEntity> groupMembers;

  GroupSettingEvent({this.type, this.groupMembers});
}

class GroupSettingEventType{
  static const int addGroupMembers = 0;
  static const int removeGroupMembers = 1;
  static const int reloadData = 2;

}