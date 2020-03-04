class GroupMemberEntity{
  int nnId;

  String nickname;

  String avatar;

  int isAdmin;

  GroupMemberEntity({this.avatar, this.nnId, this.nickname, this.isAdmin});

  GroupMemberEntity.fromJson(Map<String, dynamic> json) {
    nnId = json['nn_id'];
    nickname = json['nickname'];
    avatar = json['avatar'];
    isAdmin = json['is_admin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nn_id'] = this.nnId;
    data['nickname'] = this.nickname;
    data['avatar'] = this.avatar;
    data['is_admin'] = this.isAdmin;
    return data;
  }
}