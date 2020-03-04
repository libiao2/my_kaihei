import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/CustomDialog.dart';
import 'package:premades_nn/components/NetLoadingDialog.dart';
import 'package:premades_nn/components/loading_state.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/model/system_message_entity.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/type/AddFriendStatusType.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/SocketHelper.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'user_info.dart';

class MessageHelper extends StatefulWidget {
  @override
  _MessageHelperState createState() => _MessageHelperState();
}

class _MessageHelperState extends LoadingState<MessageHelper> {
  List<SystemMessageEntity> list = List();

  double pointDownX;

  @override
  void initLoadingState() {
    title = Strings.messageHelper;
    Constants.systemMessageCount = 0;
    initMessageHelperData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget loadingFailureWidget() {
    return null;
  }

  @override
  Widget loadingSuccessWidget() {
    return Material(
      color: ColorUtil.greyBG,
      child: Column(
        children: <Widget>[
          AppBarWidget(
            isShowBack: true,
            centerText: Strings.messageHelper,
            rightText: Strings.clear,
            callback: () {
              MyDialog.showCustomDialog(
                  context,
                  MyDialog(
                    content: "确认清空消息助手吗？",
                    confirmCallback: () {
                      bool isShow = true;
                      NetLoadingDialog.showLoadingDialog(context, "清空消息助手中..",
                          dismissCallback: () {
                        isShow = false;
                      });

                      var formData = {
                        "last_id":0
                      };
                      request("post", allUrl["ignore_all_system_messages"], formData).then((value) {
                        if (isShow) {
                          Navigator.pop(context);
                        }
                        if (value["code"] == 0) {

                          setState(() {
                            list.clear();
                          });
                        }
                      });
                    },
                  ));
            },
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: ScreenUtil().setHeight(1)),
              itemCount: list.length,
              itemBuilder: (BuildContext context, int index) {
                return messageItem(list[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget loadingWidget() {
    return null;
  }

  /// 消息item
  Widget messageItem(SystemMessageEntity item) {
    ScrollController scrollController = ScrollController();
    return SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        child: Container(
          margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(1)),
          child: Row(
            children: <Widget>[
              Listener(
                onPointerDown: (downEvent) {
                  pointDownX = downEvent.position.dx;
                  print("pointDownX = $pointDownX");
                },
                onPointerUp: (upEvent) {
                  print("upEvent = ${upEvent.position.dx}");
                  if (upEvent.position.dx - pointDownX > 0) {
                    if (upEvent.position.dx - pointDownX >
                        ScreenUtil().setWidth(50)) {
                      scrollController.jumpTo(0);
                    } else {
                      scrollController
                          .jumpTo(scrollController.position.maxScrollExtent);
                    }
                  } else {
                    if (pointDownX - upEvent.position.dx >
                        ScreenUtil().setWidth(50)) {
                      scrollController
                          .jumpTo(scrollController.position.maxScrollExtent);
                    } else {
                      scrollController.jumpTo(0);
                    }
                  }
                },
                child: InkWell(
                  child: Container(
                    width: ScreenUtil().setWidth(375),
                    height: ScreenUtil().setHeight(63),
                    child: Row(
                      children: <Widget>[
                        avatar(item),
                        mainInfo(item),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  MyDialog.showCustomDialog(
                      context,
                      MyDialog(
                        content: "确认删除该聊天吗？",
                        confirmCallback: () {
                          bool isShow = true;
                          NetLoadingDialog.showLoadingDialog(context, "删除中..",
                              dismissCallback: () {
                                isShow = false;
                              });

                          var formData = {
                            "last_id":item.msgId
                          };
                          request("post", allUrl["ignore_all_system_messages"], formData).then((value) {
                            if (isShow) {
                              Navigator.pop(context);
                            }
                            if (value["code"] == 0) {
                              scrollController.jumpTo(0);
                              setState(() {
                                list.removeWhere((listItem) {
                                  return listItem.msgId == item.msgId;
                                });
                              });
                            }
                          });
                        },
                      ));
                },
                child: Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left: ScreenUtil().setWidth(5)),
                  height: ScreenUtil().setWidth(63),
                  width: ScreenUtil().setWidth(63),
                  color: Colors.red,
                  child: Text(
                    Strings.delete,
                    style: TextStyle(
                        color: ColorUtil.white,
                        fontSize: ScreenUtil().setSp(15)),
                  ),
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: ColorUtil.white,
          ),
        ));
  }

  /// 头像
  Widget avatar(SystemMessageEntity item) {
    return Container(
      width: ScreenUtil().setWidth(45),
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipOval(
          child: Image.network(
            item.addFriendInfo.fromUser.avatar,
          ),
        ),
      ),
      margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
    );
  }

  ///用户名---验证信息
  Widget mainInfo(SystemMessageEntity item) {
    return Expanded(
      flex: 1,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    item.addFriendInfo.fromUser.nickname,
                    style: TextStyle(
                        fontSize: ScreenUtil.getInstance().setSp(15),
                        color: ColorUtil.black,
                        fontWeight: FontWeight.w500),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                  ),
                  Text(
                    item.addFriendInfo.isDealWith ? "已成为您的好友" : "请求添加您为好友",
                    style: TextStyle(
                        fontSize: ScreenUtil.getInstance().setSp(12),
                        color: Color.fromRGBO(170, 170, 170, 1)),
                    maxLines: 1,
                  )
                ],
              ),
            ),
            button(item)
          ],
        ),
        margin: EdgeInsets.only(right: 15.0),
      ),
    );
  }

  ///同意按钮---已同意标签
  Widget button(SystemMessageEntity item) {
    return !item.addFriendInfo.isDealWith
        ? InkWell(
            child: Container(
              alignment: Alignment.center,
              width: ScreenUtil().setWidth(70),
              height: ScreenUtil().setHeight(30),
              child: Text(
                '同意',
                style: TextStyle(
                    fontSize: ScreenUtil.getInstance().setSp(14),
                    color: ColorUtil.white),
              ),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [ColorUtil.btnStartColor, ColorUtil.btnEndColor],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.all(Radius.circular(20))),
            ),
            onTap: () {
              SocketHelper.addFriend(item.addFriendInfo.fromUser.nnId, null,
                  null, AddFriendStatusType.addFriendAgree);

              setState(() {
                item.addFriendInfo.isDealWith = true;
              });
            },
          )
        : Text(
            '已同意',
            style: TextStyle(
                fontSize: ScreenUtil.getInstance().setSp(14),
                color: ColorUtil.grey),
          );
  }

  void initMessageHelperData() {
    var formData = {"type": 1, "limit": 50};
    request("post", allUrl["systemMessages"], formData).then((val) {
      if (val["code"] == 0 &&
          val["data"] != null &&
          val["data"]["list"] != null) {
        (val["data"]["list"] as List).forEach((item) {
          list.add(SystemMessageEntity.fromJson(item));
        });

        if (list == null || list.length == 0) {
          loadingFailure(Strings.emptyData);
        } else {
          loadingSuccess();
        }
      } else {
        loadingFailure(Strings.emptyData);
      }
    });
  }
}
