
import 'package:premades_nn/model/list_message_entity.dart';

class UpdateMessageListEvent{
  int nnId;
  int groupNo;
  String content;//内容
  int timestamp;//时间戳
  int type;//0:不修改unread数量  1:修改
  ListMessageEntity listMessage;//消息体
  int messageType;
  UpdateMessageListEvent({this.type, this.nnId, this.content, this.timestamp, this.listMessage, this.messageType, this.groupNo});
}
