
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/NetLoadingDialog.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/event/update_group_event.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/SocketHelper.dart';
import 'package:premades_nn/utils/Strings.dart';

class EditGroupNameScreen extends StatefulWidget {

  int groupNo;

  String groupName;

  EditGroupNameScreen({this.groupNo, this.groupName});

  _EditGroupNameScreenState createState() => _EditGroupNameScreenState();
}

class _EditGroupNameScreenState extends State<EditGroupNameScreen> {
  TextEditingController _inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _inputController.text = widget.groupName;
    return Material(
      child: Column(
        children: <Widget>[
          AppBarWidget(isShowBack: true, centerText: Strings.editGroupName, rightText: Strings.save, callback: (){
            editGroupName();
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
                        hintText: widget.groupName,
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
  void editGroupName(){
    String groupName = _inputController.text;
    if (groupName == null || groupName == ""){
      toast("群聊名称不能为空！");
      return;
    }

    SocketHelper.updateGroupName(widget.groupNo, groupName);

    Constants.eventBus.fire(UpdateGroupEvent(groupNo: widget.groupNo, groupName: groupName, type: UpdateGroupType.updateGroupName));

    Navigator.pop(context);
  }
}
