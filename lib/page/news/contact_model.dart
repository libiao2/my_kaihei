import 'package:azlistview/azlistview.dart';

class ContactInfo extends ISuspensionBean {
  String name;
  String avatar;
  String tagIndex;
  String namePinyin;
  String id;

  ContactInfo({
    this.name,
    this.avatar,
    this.tagIndex,
    this.namePinyin,
    this.id
  });

  ContactInfo.fromJson(Map<String, dynamic> json)
      : name = json['name'] == null ? "" : json['name'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'avatar': avatar,
        'tagIndex': tagIndex,
        'namePinyin': namePinyin,
        'isShowSuspension': isShowSuspension
      };

  @override
  String getSuspensionTag() => tagIndex;

  @override
  // String toString() => "CityBean {" + " \"name\":\"" + name + "\"" +" \",avatar\":\"" + avatar + "\" " +" \",id\":\"" + id + "\" " + '}';
  String toString() => "CityBean {" + " \"name\":\"" + name + "\"" +" \",avatar\":\"" + avatar + "\" " +" \",id\":\"" + id + "\" " + '}';
}