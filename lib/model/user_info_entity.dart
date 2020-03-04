import 'package:premades_nn/model/search_user_entity.dart';

class UserInfoEntity {
  //生日
  String birthday;

  //绑定qq
  String qq;

  //省
  String region1;

  //市
  String region2;

  //性别 0-未知, 1-男, 2-女
  int gender;

  //是否实名认证
  bool isReal;

  //手机号
  String mobile;

  //绑定微信
  String wechat;

  //头像
  String avatar;

  //个性签名
  String intro;

  //昵称
  String nickname;

  //nnid
  int nnId;

  int specialNnId;

  //用户状态, 1-启用, 2-禁用
  int status;

  int id;

  int state;

  int level;

  bool isFriend;

  int friendVerificationType;

  //游戏卡片
  List<GameCard> card;

  //好友备注
  String remark;

  FriendInfo friendInfo;

  UserInfoEntity(
      {this.birthday,
      this.qq,
      this.region1,
      this.region2,
      this.gender,
      this.isReal,
      this.mobile,
      this.wechat,
      this.avatar,
      this.intro,
      this.nickname,
      this.nnId,
      this.specialNnId,
      this.status,
      this.id,
      this.state,
      this.isFriend,
      this.friendVerificationType,
      this.level,
      this.card,
      this.remark});

  UserInfoEntity.fromJson(Map<String, dynamic> json) {
    birthday = json['birthday'];
    qq = json['qq'];
    region1 = json['region1'];
    region2 = json['region2'];
    gender = json['gender'];
    isReal = json['is_real'];
    mobile = json['mobile'];
    wechat = json['wechat'];
    avatar = json['avatar'];
    intro = json['intro'];
    nickname = json['nickname'];
    nnId = json['nn_id'];
    specialNnId = json['special_nn_id'];
    status = json['status'];
    id = json['id'];
    state = json['state'];
    level = json['level'];
    isFriend = json['is_friend'];
    remark = json['remark'];
    friendVerificationType = json['friend_verification_type'];
    friendInfo = json["friend_info"] != null?FriendInfo.fromJson(json["friend_info"]):null;
    if (json['card'] != null){
      card = List<GameCard>();
      (json['card'] as List).map((v){
        card.add(GameCard.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['birthday'] = this.birthday;
    data['qq'] = this.qq;
    data['region1'] = this.region1;
    data['region2'] = this.region2;
    data['gender'] = this.gender;
    data['is_real'] = this.isReal;
    data['mobile'] = this.mobile;
    data['wechat'] = this.wechat;
    data['avatar'] = this.avatar;
    data['intro'] = this.intro;
    data['nickname'] = this.nickname;
    data['nn_id'] = this.nnId;
    data['special_nn_id'] = this.specialNnId;
    data['status'] = this.status;
    data['id'] = this.id;
    data['state'] = this.state;
    data['level'] = this.level;
    data['is_friend'] = this.isFriend;
    data['remark'] = this.remark;
    data['friend_verification_type'] = this.friendVerificationType;
    if (this.card != null){
      data['card'] =  this.card.map((v) => v.toJson()).toList();
    }
    if (this.friendInfo != null){
      data['friend_info'] = this.friendInfo.toJson();
    }
    return data;
  }
}

class GameCard{
  int cardId;//card_id 卡片id

  int gameId;//game_id 游戏id

  String gameName;//game_name 游戏名称

  int areaId;//area_id 大区id

  String areaName;//area_name 大区名称

  int levelId;//level_id 等级id

  String levelName;//level_name 等级名称

  String cover;//背景图

  String logo;// logo图

  List<Adept> adept;//擅长位置

  GameCard(this.cardId, this.gameId, this.gameName, this.areaId,
      this.areaName, this.levelId, this.levelName, this.cover, this.logo,
      this.adept);

  GameCard.fromJson(Map<String, dynamic> json) {
    cardId = json['card_id'];
    gameId = json['game_id'];
    gameName = json['game_name'];
    areaId = json['area_id'];
    areaName = json['area_name'];
    levelId = json['level_id'];
    levelName = json['level_name'];
    cover = json['cover'];
    logo = json['logo'];

    if (json["adept"] != null){
      adept = new List<Adept>();
      (json['adept'] as List).forEach((v) {
        adept.add(Adept.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['card_id'] = this.cardId;
    data['game_id'] = this.gameId;
    data['game_name'] = this.gameName;
    data['area_id'] = this.areaId;
    data['area_name'] = this.areaName;
    data['level_id'] = this.levelId;
    data['level_name'] = this.levelName;
    data['cover'] = this.cover;
    data['logo'] = this.logo;
    if (this.adept != null) {
      data['adept'] =  this.adept.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Adept{
  int adeptId;//adept_id 擅长位置id
  String adeptName; //adept_name 擅长位置名称

  Adept({this.adeptId, this.adeptName});

  Adept.fromJson(Map<String, dynamic> json) {
    adeptId = json['adept_id'];
    adeptName = json['adept_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['adept_id'] = this.adeptId;
    data['adept_name'] = this.adeptName;
    return data;
  }
}