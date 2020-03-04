
import 'package:path/path.dart';
import 'package:premades_nn/model/friend_info_entity.dart';
import 'package:premades_nn/model/group_entity.dart';
import 'package:premades_nn/model/group_message_item_entity.dart';
import 'package:premades_nn/model/list_message_entity.dart';
import 'package:premades_nn/model/message_item_entity.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'package:sqflite/sqflite.dart';

import 'Constants.dart';


class DBHelper {
  static String dbName = "nn.db";

  static final int _version = 1;


  static Database _database;


  ///创建数据库 根据用户id
  static void initDB() async {
    if (Constants.userInfo == null || Constants.userInfo.nnId == null) {
      return ;
    }

    String directory = await getDatabasesPath();
    String dbPath = join(directory, Constants.userInfo.nnId.toString() + "_" + dbName);
    _database = await openDatabase(dbPath, version: _version,
        onCreate: (Database db,int version) async{
          createMessageTable();
          createContactTable();
          createChatsTable();
          createGroupsTable();
          createGroupMessagesTable();
        });
  }

  ///判断表是否存在
  static Future<bool> isTableExits(String tableName) async {
    await getCurrentDatabase();
    var res = await _database.rawQuery("SELECT table_name FROM information_schema.TABLES WHERE table_name ='$tableName'");
    return res != null && res.length >0;
  }

  ///获取当前数据库对象
  static Future<Database> getCurrentDatabase() async {
    if(_database == null){
      await initDB();
    }
    return _database;
  }

  ///新建消息数据库
  static void createMessageTable() async {
    await getCurrentDatabase();

    final String SQL_MESSAGE_CREATE_TABLE =
        "CREATE TABLE message ( id INTEGER PRIMARY KEY, msg_id INT(10), from_id INT(10), to_id INT(10),"
        " timestamp INT(20), message_type TINYINT(1),is_read TINYINT(1),content TEXT, voice_duration INT(5),call_duration INT(10),"
        " call_status TINYINT(1), sequence_id INT(20), send_type TINYINT(1), image_height INT(10), image_width INT(10))";
    await _database.execute(SQL_MESSAGE_CREATE_TABLE);
  }

  ///新建好友数据库
  static void createContactTable() async {
    await getCurrentDatabase();

    final String SQL_CONTACT_CREATE_TABLE =
        "CREATE TABLE contact ( id INTEGER PRIMARY KEY, nn_id INT(10), special_nn_id INT(10), avatar varchar(256), "
        "nickname varchar(16), gender TINYINT(1),intro varchar(128),region1 varchar(20), region2 varchar(20), "
        "remark varchar(16), first_letter char(1), friend_from TINYINT(1) )";
    await _database.execute(SQL_CONTACT_CREATE_TABLE);
  }

  ///新建最近回话（最近联系人）数据库
  static void createChatsTable() async {
    await getCurrentDatabase();

    final String SQL_CHATS_CREATE_TABLE =
        "CREATE TABLE chat ( id INTEGER PRIMARY KEY, unread_count INT(10), timestamp INT(20), nn_id INT(10), special_nn_id INT(10),"
        "nickname varchar(16), message_type TINYINT(1),gender TINYINT(1),content TEXT, avatar varchar(255), send_type TINYINT(1), is_friend TINYINT(1),"
        "groups_no INT(10), groups_name varchar(50),message_category TINYINT(1))";
    await _database.execute(SQL_CHATS_CREATE_TABLE);
  }


  ///群聊表
  static void createGroupsTable() async {
    await getCurrentDatabase();

    final String SQL_GROUPS_CREATE_TABLE =
        "CREATE TABLE groups ( id INTEGER PRIMARY KEY, groups_no INT(10), groups_name varchar(16), "
        "avatar varchar(255), first_letter char(1))";
    await _database.execute(SQL_GROUPS_CREATE_TABLE);
  }

  ///群聊消息表
  static void createGroupMessagesTable() async {
    await getCurrentDatabase();

    final String sql =
        "CREATE TABLE group_message ( id INTEGER PRIMARY KEY, groups_no INT(10),timestamp INT(20), content TEXT"
        " ,msg_id INT(10), message_type TINYINT(1), avatar varchar(255), nickname varchar(16), nn_id INT(10),"
        " isRead TINYINT(1),voice_duration INT(5),call_duration INT(10),call_status TINYINT(1),"
        " sequence_id INT(20), send_type TINYINT(1), image_height INT(10), image_width INT(10))";
    await _database.execute(sql);
  }

  ///关闭数据库
  static void close(){
    if (_database != null){
      _database.close();
    }
  }

  ///------------------------------------------------------------------------------------------------------------------------------------------------------------
  ///-----------------------------------------------------------------------群聊 表 操作---------------------------------------------------------------------------
  ///------------------------------------------------------------------------------------------------------------------------------------------------------------

  ///添加群
  static Future insertGroup(GroupEntity groupEntity) async {
    await getCurrentDatabase();
    String sql = "INSERT INTO groups(groups_no, groups_name, "
        "avatar, first_letter) VALUES (${groupEntity.groupsNo}, '${groupEntity.groupsName}',"
        " '${groupEntity.avatar}' , '${groupEntity.firstLetter}')";
    int count = await queryCountByGroupNo(groupEntity.groupsNo);
    if (count == 0){
      await _database.rawInsert(sql);
    }
  }

  ///添加多个群聊
  static Future insertGroups(List<GroupEntity> groups) async {
    if(groups != null && groups.length > 0){
      for(int i = 0; i < groups.length; i++){
        await insertGroup(groups[i]);
      }
    }
  }

  ///查找群是否已保存
  static Future<int> queryCountByGroupNo(int groupNo) async {
    await getCurrentDatabase();
    String sql = "SELECT count(1) FROM groups WHERE groups_no = $groupNo";
    int count = Sqflite.firstIntValue(await _database.rawQuery(sql));
    return count;
  }

  ///刪除群聊
  static Future deleteGroupByGroupNo(int groupNo) async {
    await getCurrentDatabase();
    String sql = "DELETE FROM groups WHERE groups_no = $groupNo";
    await _database.rawDelete(sql);
  }

  ///修改群聊
  static Future updateGroupByGroupNo(GroupEntity groupEntity) async {
    await getCurrentDatabase();
    String sqlMessageUpdate =
        "UPDATE groups SET groups_name = '${groupEntity.groupsName}',avatar = '${groupEntity.avatar}',"
        " first_letter = '${groupEntity.firstLetter}'  WHERE groups_no = ${groupEntity.groupsNo}";
    await _database.rawUpdate(sqlMessageUpdate);
  }

  ///查询所有群聊
  static Future<List<GroupEntity>> queryAllGroups() async {
    await getCurrentDatabase();
    String sql = "SELECT * FROM groups";
    List<Map> queryDatas = await _database.rawQuery(sql);

    List<GroupEntity> result = new List();
    queryDatas.forEach((v){
      result.add(GroupEntity.fromJson(v));
    });
    return result;
  }

  ///------------------------------------------------------------------------------------------------------------------------------------------------------------
  ///-----------------------------------------------------------------------消息 表 操作---------------------------------------------------------------------------
  ///------------------------------------------------------------------------------------------------------------------------------------------------------------

  ///插入一条消息数据
  ///每个用户只存入100条消息, 大于等于100先删除再添加
  static Future insertMessage(MessageItemEntity message, int nnId) async {
    await getCurrentDatabase();
    if (message.extra == null){
      message.extra = ExtraData();
    }
    String sqlMessageInsert =
        "INSERT INTO message(msg_id, from_id, to_id, timestamp, message_type, is_read, content, voice_duration, call_duration, call_status, sequence_id, send_type, "
        "image_height, image_width) "
        "VALUES(${message.msgId}, ${message.fromId}, ${message.toId},${message.timestamp}, ${message.messageType}, ${message.isRead == true?1:0},"
        " '${message.content}', ${message.extra.voiceDuration}, ${message.extra.callDuration}, ${message.extra.callStatus},${message.sequenceId},${message.sendType},"
        "${message.extra.imageHeight}, ${message.extra.imageWidth})";

    int count = await queryMessageCountByUserId(nnId);
    if (count >= 100){
      String sqlMessageDelete = "DELETE FROM message where id = (SELECT id FROM message WHERE from_id = $nnId OR to_id = $nnId ORDER BY timestamp ASC LIMIT 1)";
      _database.transaction((transaction) async {
        await transaction.rawDelete(sqlMessageDelete);
        await transaction.rawInsert(sqlMessageInsert);
      });
    } else {
      await _database.rawInsert(sqlMessageInsert);
    }
  }

  ///插入多条消息数据
  ///只存入100条消息
  static void insertMessages(List<MessageItemEntity> messages, int nnId) async {

//    if (await isTableExits("message")){
      await deleteMessages(nnId);
//    }

    for(int i = 0; i < messages.length; i++){
      await insertMessage(messages[i], nnId);
    }
  }

  ///删除单个用户消息数据
  static Future deleteMessages(int nnId) async {
    await getCurrentDatabase();
    String sqlMessageDelete =
        "DELETE FROM message where from_id = $nnId or to_id = $nnId";
    await _database.rawDelete(sqlMessageDelete);
  }

  ///更新消息数据
  static Future updateMessageRead(int nnId) async {
    await getCurrentDatabase();
    String sqlMessageUpdate =
        "UPDATE message SET is_read = 1 WHERE to_id = $nnId OR from_id = $nnId ";
    await _database.rawUpdate(sqlMessageUpdate);
  }

  ///查询用户的所有聊天记录
  static Future<List<MessageItemEntity>> queryMessagesByUserId(int nnId) async {
    await getCurrentDatabase();
    String sqlMessageQuery = "SELECT * FROM message WHERE to_id = $nnId OR from_id = $nnId";
    List<Map> queryDatas = await _database.rawQuery(sqlMessageQuery);

    List<MessageItemEntity> result = new List();
    queryDatas.forEach((v){
      MessageItemEntity messageItem = MessageItemEntity.fromJson(v);
      messageItem.extra = ExtraData(voiceDuration: v["voice_duration"], callDuration: v["call_duration"],
        callStatus: v["call_status"],imageHeight: v["image_height"], imageWidth: v["image_width"]);
      result.add(messageItem);
    });
    return result;
  }

  ///查询用户聊天记录条数
  static Future<int> queryMessageCountByUserId(int nnId) async {
    await getCurrentDatabase();
    String sqlMessageQuery = "SELECT count(1) FROM message WHERE from_id = $nnId OR to_id = $nnId";
    int count = Sqflite.firstIntValue(await _database.rawQuery(sqlMessageQuery));
    return count;
  }


  ///------------------------------------------------------------------------------------------------------------------------------------------------------------
  ///-----------------------------------------------------------------------群聊消息--------------------------------------------------------------------------
  ///------------------------------------------------------------------------------------------------------------------------------------------------------------

  ///插入一条群消息数据
  ///每个用户只存入100条消息, 大于等于100先删除再添加
  static Future insertGroupMessage(GroupMessageItemEntity groupMessage) async {
    await getCurrentDatabase();
    String sqlMessageInsert =
        "INSERT INTO group_message(groups_no, msg_id, message_type, avatar,"
        "content, timestamp, nickname, nn_id,"
        " isRead,voice_duration,call_duration ,call_status ,"
        " sequence_id , send_type , image_height, image_width) "
        "VALUES(${groupMessage.groupNo}, ${groupMessage.msgId}, ${groupMessage.messageType},'${groupMessage.fromAvatar}',"
        " '${groupMessage.content}',${groupMessage.timestamp}, '${groupMessage.fromNickname}',"
        " ${groupMessage.fromNnid}, ${groupMessage.isRead == true?1:0},"
        " ${groupMessage.extra.voiceDuration}, ${groupMessage.extra.callDuration}, ${groupMessage.extra.callStatus},${groupMessage.sequenceId},${groupMessage.sendType},"
        "${groupMessage.extra.imageHeight}, ${groupMessage.extra.imageWidth})";

    int count = await queryGroupMessageCountByGroupNo(groupMessage.groupNo);
    if (count >= 100){
      String sqlMessageDelete = "DELETE FROM group_message where id = (SELECT id FROM group_message WHERE groups_no = ${groupMessage.groupNo} ORDER BY timestamp ASC LIMIT 1)";
      _database.transaction((transaction) async {
        await transaction.rawDelete(sqlMessageDelete);
        await transaction.rawInsert(sqlMessageInsert);
      });
    } else {
      await _database.rawInsert(sqlMessageInsert);
    }
  }

  ///查询群聊天记录条数
  static Future<int> queryGroupMessageCountByGroupNo(int groupNo) async {
    await getCurrentDatabase();
    String sqlMessageQuery = "SELECT count(1) FROM group_message WHERE groups_no = $groupNo";
    int count = Sqflite.firstIntValue(await _database.rawQuery(sqlMessageQuery));
    return count;
  }

  ///插入多条群消息数据
  ///只存入100条消息
  static void insertGroupMessages(List<GroupMessageItemEntity> messages, int groupNo) async {

//    if (await isTableExits("message")){
    await deleteGroupByGroupNo(groupNo);
//    }

    for(int i = 0; i < messages.length; i++){
      await insertGroupMessage(messages[i]);
    }
  }

  ///删除单个群的群消息数据
  static Future deleteGroupMessages(int groupNo) async {
    await getCurrentDatabase();
    String sqlMessageDelete =
        "DELETE FROM group_message where groups_no = $groupNo";
    await _database.rawDelete(sqlMessageDelete);
  }

  ///查询用户的所有聊天记录
  static Future<List<GroupMessageItemEntity>> queryGroupMessagesByGroupNo(int groupNo) async {
    await getCurrentDatabase();
    String sqlMessageQuery = "SELECT * FROM group_message WHERE groups_no = $groupNo";
    List<Map> queryDatas = await _database.rawQuery(sqlMessageQuery);

    List<GroupMessageItemEntity> result = new List();
    queryDatas.forEach((v){
      GroupMessageItemEntity messageItem = GroupMessageItemEntity.fromJson(v);
      messageItem.fromNnid = v["nn_id"];
      messageItem.fromAvatar = v["avatar"];
      messageItem.fromNickname = v["nickname"];
      messageItem.extra = ExtraData(voiceDuration: v["voice_duration"], callDuration: v["call_duration"],
          callStatus: v["call_status"],imageHeight: v["image_height"], imageWidth: v["image_width"]);
      result.add(messageItem);
    });
    return result;
  }


///------------------------------------------------------------------------------------------------------------------------------------------------------------
///-----------------------------------------------------------------------好友 表 操作-------------------------------------------------------------------------
///------------------------------------------------------------------------------------------------------------------------------------------------------------

  ///添加单个好友
  static Future insertFriendInfo(FriendInfoEntity friendInfo) async {
    if (friendInfo == null){
      return;
    }

    await getCurrentDatabase();
    int count = await queryContactCountByUserId(friendInfo.nnId);
    //数据库没数据再添加
    if (count == 0){
      String sqlMessageInsert =
          "INSERT INTO contact(nn_id, special_nn_id, avatar, nickname, gender,intro,region1, region2, remark, first_letter, friend_from) "
          "VALUES(${friendInfo.nnId}, ${friendInfo.specialNnId}, '${friendInfo.avatar}', '${friendInfo.nickname}', ${friendInfo.gender}, '${friendInfo.intro}',"
          "'${friendInfo.region1}', '${friendInfo.region2}', '${friendInfo.remark}', '${friendInfo.firstLetter}', ${friendInfo.friendFrom})";
      await _database.rawInsert(sqlMessageInsert);
    } else {
      print("添加数据库失败， 好友已存在!");
    }
  }

  ///添加好友
  static Future insertFriendsInfo(List<FriendInfoEntity> friendsInfo) async {
    if (friendsInfo == null || friendsInfo.length ==0){
      return;
    }

    await deleteAllFriendsInfo();

    for(int i = 0; i < friendsInfo.length; i++){
    await insertFriendInfo(friendsInfo[i]);
    }
  }

  ///查询该好友是否存在
  static Future queryContactCountByUserId(int nnId) async {
    if (nnId == null){
      return 0;
    }
    await getCurrentDatabase();
    String sql = "SELECT count(1) FROM contact WHERE nn_id = $nnId";
    int count = Sqflite.firstIntValue(await _database.rawQuery(sql));
    return count;
  }

  ///删除所有好友
  static Future deleteAllFriendsInfo() async {
    await getCurrentDatabase();
    String sqlMessageDelete =
        "DELETE FROM contact";
    await _database.rawDelete(sqlMessageDelete);
  }

  ///删除好友
  static Future deleteFriendsInfo(int nnId) async {
    await getCurrentDatabase();
    String sql = "DELETE FROM contact WHERE nn_id = $nnId";
    await _database.rawDelete(sql);
  }

  ///更新好友修改备注
  static Future updateFriendRemarkName(int nnId, String remark) async {
    if (nnId == null || remark == null){
      return;
    }
    await getCurrentDatabase();
    String sql = "UPDATE contact SET remark = '$remark' where nn_id = $nnId";
    await _database.rawUpdate(sql);
  }

  static Future<String> getFriendRemarkByNnId(int nnId) async {
    String remark;

    if (nnId == null){
      return remark;
    }

    await getCurrentDatabase();
    String sql = "SELECT remark FROM contact WHERE nn_id = $nnId";
    List<Map> queryDatas = await _database.rawQuery(sql);
    if(queryDatas.length == 1){
      remark = queryDatas[0]["remark"];
    }
    return remark;
  }

  static Future<List<FriendInfoEntity>> queryContacts() async {
    await getCurrentDatabase();
    String sqlMessageQuery = "SELECT * FROM contact";
    List<Map> queryDatas = await _database.rawQuery(sqlMessageQuery);

    List<FriendInfoEntity> result = new List();
    queryDatas.forEach((v){
      result.add(FriendInfoEntity.fromJson(v));
    });
    return result;
  }

///------------------------------------------------------------------------------------------------------------------------------------------------------------
///---------------------------------------------------------------------最近联系人 表 操作---------------------------------------------------------------------
///------------------------------------------------------------------------------------------------------------------------------------------------------------


  ///添加最近回话（最近联系人）
  ///"CREATE TABLE chat ( id INTEGER PRIMARY KEY, unread_count INT(10), timestamp INT(20), nn_id INT(10), special_nn_id INT(10),"
  ///        "nickname varchar(16), message_type TINYINT(1),gender TINYINT(1),content TEXT, avatar varchar(255), send_type TINYINT(1))";
  static Future insertChat(ListMessageEntity listMessage) async {
    if (listMessage == null){
      return;
    }

    await getCurrentDatabase();
      int isFriend;
      if(listMessage.isFriend){
        isFriend = 1;
      } else {
        isFriend = 0;
      }
      String sqlMessageInsert =
          "INSERT INTO chat(unread_count, timestamp, nn_id, special_nn_id, nickname, message_type, gender,"
          " content, avatar, send_type, is_friend, groups_no, groups_name, message_category) "
          "VALUES(${listMessage.unreadCount}, ${listMessage.timestamp}, ${listMessage.nnId}, ${listMessage.specialNnId}, '${listMessage.nickname}',"
          "${listMessage.messageType}, ${listMessage.gender}, '${listMessage.content}','${listMessage.avatar}', ${listMessage.sendType},"
          " $isFriend, ${listMessage.groupsNo}, '${listMessage.groupsName}', ${listMessage.messageCategory})";
      await _database.rawInsert(sqlMessageInsert);

  }

  ///添加最近回话（最近联系人）
  static Future insertChats(List<ListMessageEntity> chats) async {
    if (chats == null || chats.length ==0){
      return;
    }

    await deleteAllChat();

    for(int i = 0; i < chats.length; i++){
      await insertChat(chats[i]);
    }
  }

  ///根据userId获取最近回话（最近联系人）
  static Future<int> queryChatCountByUserIdOrGroupNo({int nnId, int groupNo}) async {
    if (nnId == null && groupNo == null){
      return null;
    }

    await getCurrentDatabase();
    int count;
    if (nnId != null){
      String sql = "SELECT COUNT(1) FROM chat WHERE nn_id = $nnId";
      count = Sqflite.firstIntValue(await _database.rawQuery(sql));
    } else if (groupNo != null){
      String sql = "SELECT COUNT(1) FROM chat WHERE groups_no = $groupNo";
      count = Sqflite.firstIntValue(await _database.rawQuery(sql));
    }

    return count;
  }


  ///获取所有回话
  static Future<List<ListMessageEntity>> queryAllChat() async {
    await getCurrentDatabase();
    String sqlMessageQuery = "SELECT * FROM chat";
    List<Map> queryDatas = await _database.rawQuery(sqlMessageQuery);

    List<ListMessageEntity> result = new List();
    queryDatas.forEach((v){
      if (v["message_category"] == MessageCategory.chat){
        result.add(ListMessageEntity.fromJson(v));
      } else if(v["message_category"] == MessageCategory.groupChat){
        result.add(ListMessageEntity.fromGroupJson(v));
      }
    });
    return result;
  }


  ///删除回话表所有数据
  static Future deleteAllChat() async {
    await getCurrentDatabase();
    String sql = "DELETE FROM chat";
    await _database.rawDelete(sql);
  }


  ///删除单个回话
  static Future deleteChat({int nnId, int groupNo}) async {
    await getCurrentDatabase();
    if (nnId != null){
      String sql = "DELETE FROM chat WHERE nn_id = $nnId";
      await _database.rawDelete(sql);
    } else if(groupNo != null){
      String sql = "DELETE FROM chat WHERE groups_no = $groupNo";
      await _database.rawDelete(sql);
    }

  }


  ///更新会话
  static Future updateChat(ListMessageEntity listMessageEntity) async {
    if (listMessageEntity == null){
      return;
    }

    if (listMessageEntity.messageCategory == MessageCategory.chat){
      int count = await queryChatCountByUserIdOrGroupNo(nnId: listMessageEntity.nnId);
      if (count == 0){
        insertChat(listMessageEntity);
      } else {
        String sql = "UPDATE chat SET unread_count = ${listMessageEntity.unreadCount}, timestamp = ${listMessageEntity.timestamp}, "
            "message_type = ${listMessageEntity.messageType}, content = '${listMessageEntity.content}' WHERE nn_id = ${listMessageEntity.nnId}";
        await _database.rawUpdate(sql);
      }
    } else if (listMessageEntity.messageCategory == MessageCategory.groupChat){
      int count = await queryChatCountByUserIdOrGroupNo(groupNo: listMessageEntity.groupsNo);
      if (count == 0){
        insertChat(listMessageEntity);
      } else {
        String sql = "UPDATE chat SET unread_count = ${listMessageEntity.unreadCount}, timestamp = ${listMessageEntity.timestamp}, "
            "message_type = ${listMessageEntity.messageType}, content = '${listMessageEntity.content}' WHERE groups_no = ${listMessageEntity.groupsNo}";
        await _database.rawUpdate(sql);
      }
    }
  }
}
