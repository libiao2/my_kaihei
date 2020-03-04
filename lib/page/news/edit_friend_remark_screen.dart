import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/NetLoadingDialog.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/event/add_friend_event.dart';
import 'package:premades_nn/event/update_screen_event.dart';
import 'package:premades_nn/model/user_info_entity.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/DBHelper.dart';
import 'package:premades_nn/utils/Strings.dart';

class EditFriendRemarkScreen extends StatefulWidget {

  UserInfoEntity userInfo;

  EditFriendRemarkScreen({this.userInfo});

  _EditFriendRemarkScreenState createState() => _EditFriendRemarkScreenState();
}

class _EditFriendRemarkScreenState extends State<EditFriendRemarkScreen> {
  TextEditingController _inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _inputController.text = widget.userInfo.nickname;
    return Material(
      child: Column(
        children: <Widget>[
          AppBarWidget(isShowBack: true, centerText: Strings.editFriendRemark, rightText: Strings.save, callback: (){
            editFriendRemark();
          },),
          Container(
            height: ScreenUtil().setHeight(40),
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _inputController,
                    autofocus: true,
                    cursorColor: ColorUtil.black,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        hintText: widget.userInfo.nickname,
                        hintStyle: TextStyle(
                            color: Color.fromRGBO(207, 207, 207, 1),
                            fontSize: ScreenUtil.getInstance().setSp(14)),
                        border: OutlineInputBorder(
                          // borderRadius: BorderRadius.circular(15.0),
                            borderSide: BorderSide.none)),
//                  onChanged: _onChanged,
                  ),
                )
              ],
            ),
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Color.fromRGBO(242, 242, 242, 1),
                borderRadius: BorderRadius.all(Radius.circular(20))),
          )
        ],
      ),
    );;
  }

  @override
  void initState() {
    super.initState();
  }

  //修改昵称
  void editFriendRemark(){
    String remark = _inputController.text;
    if (remark == null || remark == ""){
      toast("备注不能为空！");
      return;
    }


    NetLoadingDialog.showLoadingDialog(context, "修改备注中...");

      var formData = {"friend_id": widget.userInfo.nnId, "remark": remark};
      request("post", allUrl["updateUserRemark"], formData).then((result) {
        Navigator.of(context).pop();
        if (result["code"] == 0) {
          Navigator.of(context).pop();

          toast("修改好友备注成功！");

          Constants.eventBus.fire(AddFriendEvent(type: FriendInfoUpdateType.updateRemark, remark: remark, nnId: widget.userInfo.nnId));

          Constants.eventBus.fire(AddFriendSuccessEvent());

          DBHelper.updateFriendRemarkName(widget.userInfo.nnId, remark);
        }
      });
  }
}
