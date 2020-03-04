import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/model/friend_info_entity.dart';
import 'package:premades_nn/utils/ColorUtil.dart';

class FriendCheckItem extends StatefulWidget {
  final Function callback;

  final FriendInfoEntity model;

  final bool enable;

  FriendCheckItem({this.model, this.callback, this.enable});

  @override
  State<StatefulWidget> createState() => FriendCheckItemState();
}

class FriendCheckItemState extends State<FriendCheckItem> {
  final int _itemHeight = 60;

  bool isCheck = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enable) {
      return Container(
          height: _itemHeight.toDouble(),
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Container(
                  width: ScreenUtil().setWidth(44),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipOval(
                      child: Image.network(
                        widget.model.avatar,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  widget.model.remark != null && widget.model.remark != ""
                      ? widget.model.remark
                      : widget.model.nickname,
                  style: TextStyle(
                      color: ColorUtil.black, fontSize: ScreenUtil().setSp(15)),
                ),
                trailing: Image.asset(
                  "images/icon_disable.png",
                  width: ScreenUtil().setWidth(18),
                  fit: BoxFit.fitWidth,
                ),
              )
            ],
          ));
    }
    return Container(
        height: _itemHeight.toDouble(),
        child: Column(
          children: <Widget>[
            ListTile(
              onTap: (){
                onClick();
              },
              leading: Container(
                width: ScreenUtil().setWidth(44),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipOval(
                    child: Image.network(
                      widget.model.avatar,
                    ),
                  ),
                ),
              ),
              title: Text(
                widget.model.remark != null && widget.model.remark != ""
                    ? widget.model.remark
                    : widget.model.nickname,
                style: TextStyle(
                    color: ColorUtil.black, fontSize: ScreenUtil().setSp(15)),
              ),
              trailing: Image.asset(
                !isCheck
                    ? "images/icon_checkbox.png"
                    : "images/icon_checkbox_on.png",
                width: ScreenUtil().setWidth(18),
                fit: BoxFit.fitWidth,
              ),
            )
          ],
        ));
  }

  void onClick(){
    setState(() {
      isCheck = !isCheck;
    });

    if (widget.callback != null) {
      widget.callback();
    }
  }
}
