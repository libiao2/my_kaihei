import 'package:azlistview/azlistview.dart';

class FriendInfoEntity extends ISuspensionBean{

	int nnId;//用户nnid

	int specialNnId;//靓号

	String avatar;//头像地址

	String nickname;//昵称

	int gender;//性别

	String intro;//个性签名

	String region1;//地址-省

	String region2;//地址-市

	String remark;//备注

	int friendFrom;//好友来源  1：搜索    2：频道内

	String firstLetter;//首字母

	FriendInfoEntity({this.nnId, this.specialNnId, this.avatar, this.nickname,
		this.gender, this.intro, this.region1, this.region2, this.remark,
		this.friendFrom, this.firstLetter});


	FriendInfoEntity.fromJson(Map<String, dynamic> json) {
		nnId = json['nn_id'];
		specialNnId = json['special_nn_id'];
		avatar = json['avatar'];
		nickname = json['nickname'];
		gender = json['gender'];
		intro = json['intro'];
		region1 = json['region1'];
		region2 = json['region2'];
		remark = json['remark'];
		friendFrom = json['friend_from'];
		firstLetter = json['first_letter'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['nn_id'] = this.nnId;
		data['special_nn_id'] = this.specialNnId;
		data['avatar'] = this.avatar;
		data['nickname'] = this.nickname;
		data['gender'] = this.gender;
		data['intro'] = this.intro;
		data['region1'] = this.region1;
		data['region2'] = this.region2;
		data['remark'] = this.remark;
		data['friend_from'] = this.friendFrom;
		data['first_letter'] = this.firstLetter;
		return data;
	}

  @override
  String getSuspensionTag() => firstLetter;
}
