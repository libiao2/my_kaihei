import 'package:azlistview/azlistview.dart';

class GroupEntity  extends ISuspensionBean{

  int groupsNo;

  String groupsName;

  String avatar;

  String firstLetter;

  GroupEntity({this.avatar, this.firstLetter, this.groupsName, this.groupsNo});

  GroupEntity.fromJson(Map<String, dynamic> json) {
    groupsNo = json['groups_no'];
    groupsName = json['groups_name'];
    avatar = json['avatar'];
    firstLetter = json['first_letter'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groups_no'] = this.groupsNo;
    data['groups_name'] = this.groupsName;
    data['avatar'] = this.avatar;
    data['first_letter'] = this.firstLetter;
    return data;
  }

  @override
  String getSuspensionTag() => firstLetter;
}