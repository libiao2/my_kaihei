import 'package:premades_nn/model/group_entity.dart';

class UpdateGroupEvent{

  int type;

  int groupNo;

  String groupName;

  GroupEntity groupEntity;

  UpdateGroupEvent({this.groupName, this.groupNo, this.type, this.groupEntity});
}

class UpdateGroupType{
  static const updateGroupName = 0;
  static const addGroup = 1;
  static const exitGroup = 2;
}