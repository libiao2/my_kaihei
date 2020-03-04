class SystemMessageEntity {
	bool isRead;
	AddFriendInfo addFriendInfo;
	int msgId;
	int type;
	String content;
	int timestamp;

	SystemMessageEntity({this.isRead, this.addFriendInfo, this.msgId, this.type, this.content, this.timestamp});

	SystemMessageEntity.fromJson(Map<String, dynamic> json) {
		isRead = json['is_read'];
		addFriendInfo = json['add_friend_info'] != null ? new AddFriendInfo.fromJson(json['add_friend_info']) : null;
		msgId = json['msg_id'];
		type = json['type'];
		content = json['content'];
		timestamp = json['timestamp'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['is_read'] = this.isRead;
		if (this.addFriendInfo != null) {
      data['add_friend_info'] = this.addFriendInfo.toJson();
    }
		data['msg_id'] = this.msgId;
		data['type'] = this.type;
		data['content'] = this.content;
		data['timestamp'] = this.timestamp;
		return data;
	}
}

class AddFriendInfo {
	bool isDealWith;
	int from;
	FromUser fromUser;
	int status;

	AddFriendInfo({this.isDealWith, this.from, this.fromUser, this.status});

	AddFriendInfo.fromJson(Map<String, dynamic> json) {
		isDealWith = json['is_deal_with'];
		from = json['from'];
		fromUser = json['from_user'] != null ? new FromUser.fromJson(json['from_user']) : null;
		status = json['status'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['is_deal_with'] = this.isDealWith;
		data['from'] = this.from;
		if (this.fromUser != null) {
      data['from_user'] = this.fromUser.toJson();
    }
		data['status'] = this.status;
		return data;
	}
}

class FromUser {
	int gender;
	String nickname;
	int nnId;
	String avatar;
	int specialNnId;

	FromUser({this.gender, this.nickname, this.nnId, this.avatar, this.specialNnId});

	FromUser.fromJson(Map<String, dynamic> json) {
		gender = json['gender'];
		nickname = json['nickname'];
		nnId = json['nn_id'];
		avatar = json['avatar'];
		specialNnId = json['special_nn_id'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['gender'] = this.gender;
		data['nickname'] = this.nickname;
		data['nn_id'] = this.nnId;
		data['avatar'] = this.avatar;
		data['special_nn_id'] = this.specialNnId;
		return data;
	}
}
