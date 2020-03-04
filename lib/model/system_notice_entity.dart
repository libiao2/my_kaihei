
///系统公告
class SystemNoticeEntity{

  int id; //公告id

  String title; //公告名称

  String cover; //公告背景图

  int releaseTime; //公告发送时间

  SystemNoticeEntity({this.id, this.title, this.cover, this.releaseTime});

  SystemNoticeEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    cover = json['cover'];
    releaseTime = json['release_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groups_no'] = this.id;
    data['groups_name'] = this.title;
    data['avatar'] = this.cover;
    data['release_time'] = this.releaseTime;
    return data;
  }

}