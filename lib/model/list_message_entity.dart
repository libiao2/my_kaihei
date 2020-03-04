class ListMessageEntity {
	int messageCategory;//1：单聊   0：群聊
	int unreadCount; // 未读消息数
	int timestamp; // 消息创建时间戳
	String nickname;  // 消息用户昵称
	String avatar;  // 消息用户昵称
	int gender;  // 消息用户昵称
	int messageType; // 消息类型 		1文字	 2图片	3录音	4语音通话	5系统消息	99自定义消息（如：nn://room/enter?id=639712&title=飞机票）
	int nnId;  // 消息ID
	int specialNnId;  // NN靓号
	String content; // 消息内容-最后一条消息
	int sendType;//0:发送中  1：已发送  2：发送失败
	bool isFriend;//是否是好友
	dynamic friendInfo;

	int groupsNo;//群号
	String groupsName;//群名称

	ListMessageEntity({this.unreadCount, this.nickname, this.messageType, this.nnId, this.content,
		this.avatar, this.sendType, this.gender, this.specialNnId, this.timestamp, this.friendInfo, this.isFriend, this.groupsNo, this.groupsName});

	ListMessageEntity.fromJson(Map<String, dynamic> json) {
		messageCategory = MessageCategory.chat;
		unreadCount = json['unread_count'];
		nickname = json['nickname'];
		avatar = json['avatar'];
		gender = json['gender'];
		messageType = json['message_type'];
		nnId = json['nn_id'];
		specialNnId = json['special_nn_id'];
		content = json['content'];
		timestamp = json['timestamp'];
		sendType = json['send_type'] == null ? 1 : json['send_type'];
		friendInfo = json['friend_info'];
		if (json['is_friend'] == 1){
			isFriend = true;
		} else {
			isFriend = false;
		}
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['nickname'] = this.nickname;
		data['unread_count'] = this.unreadCount;
		data['avatar'] = this.avatar;
		data['gender'] = this.gender;
		data['message_type'] = this.messageType;
		data['nn_id'] = this.nnId;
		data['special_nn_id'] = this.specialNnId;
		data['content'] = this.content;
		data['send_type'] = this.sendType;
		data['timestamp'] = this.timestamp;
		data['friend_info'] = this.friendInfo;
		data['is_friend'] = this.isFriend;
		data['message_category'] = this.messageCategory;
		return data;
	}

	ListMessageEntity.fromGroupJson(Map<String, dynamic> json) {
		messageCategory = MessageCategory.groupChat;
		unreadCount = json['unread_count'];
		groupsNo = json['groups_no'];
		groupsName = json['groups_name'];
		avatar = json['avatar'];
		messageType = json['message_type'];
		content = json['content'];
		timestamp = json['timestamp'];
		sendType = json['send_type'] == null ? 1 : json['send_type'];
	}

	Map<String, dynamic> toGroupJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['unread_count'] = this.unreadCount;
		data['avatar'] = this.avatar;
		data['message_type'] = this.messageType;
		data['content'] = this.content;
		data['send_type'] = this.sendType;
		data['timestamp'] = this.timestamp;
		data['message_category'] = this.messageCategory;
		return data;
	}
}

class MessageCategory{
	static const int chat = 1;
	static const int groupChat = 0;
}
