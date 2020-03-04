class SearchUserEntity {
	String msg;
	int code;
	SearchUserData data;

	SearchUserEntity({this.msg, this.code, this.data});

	SearchUserEntity.fromJson(Map<String, dynamic> json) {
		msg = json['msg'];
		code = json['code'];
		data = json['data'] != null ? new SearchUserData.fromJson(json['data']) : null;
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['msg'] = this.msg;
		data['code'] = this.code;
		if (this.data != null) {
			data['data'] = this.data.toJson();
		}
		return data;
	}
}

class SearchUserData {
	int limit;
	bool hasMore;
	List<SearchUser> searchUserList;

	SearchUserData({this.limit, this.hasMore, this.searchUserList});

	SearchUserData.fromJson(Map<String, dynamic> json) {
		limit = json['limit'];
		hasMore = json['has_more'];
		if (json['list'] != null) {
			searchUserList = new List<SearchUser>();(json['list'] as List).forEach((v) { searchUserList.add(new SearchUser.fromJson(v)); });
		}
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['limit'] = this.limit;
		data['has_more'] = this.hasMore;
		if (this.searchUserList != null) {
			data['list'] =  this.searchUserList.map((v) => v.toJson()).toList();
		}
		return data;
	}
}

class SearchUser {
	int gender;
	String intro;
	String nickname;
	int nnId;
	String avatar;
	int isFriend;
	int friendVerificationType;
	FriendInfo friendInfo;

	SearchUser({this.gender, this.intro, this.nickname, this.nnId, this.avatar, this.isFriend, this.friendVerificationType});

	SearchUser.fromJson(Map<String, dynamic> json) {
		gender = json['gender'];
		intro = json['intro'];
		nickname = json['nickname'];
		nnId = json['nn_id'];
		avatar = json['avatar'];
		isFriend = json['is_friend'];
		friendVerificationType = json['friend_verification_type'];
		friendInfo = json["friend_info"] != null?FriendInfo.fromJson(json["friend_info"]):null;
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['gender'] = this.gender;
		data['intro'] = this.intro;
		data['nickname'] = this.nickname;
		data['nn_id'] = this.nnId;
		data['avatar'] = this.avatar;
		data['is_friend'] = this.isFriend;
		data['friend_verification_type'] = this.friendVerificationType;
		if (this.friendInfo != null){
			data['friend_info'] = this.friendInfo.toJson();
		}
		return data;
	}

}

class FriendInfo{
	String friendRemark;
	int friendFrom;

	FriendInfo({this.friendFrom, this.friendRemark});

	FriendInfo.fromJson(Map<String, dynamic> json) {
		friendRemark = json['friend_remark'];
		friendFrom = json['friend_from'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['friend_remark'] = this.friendRemark;
		data['friend_from'] = this.friendFrom;
		return data;
	}
}
