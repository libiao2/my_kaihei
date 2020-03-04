import 'dart:ui';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/components/my_special_text_span_builder.dart';
import 'package:premades_nn/components/toast.dart';
import 'package:premades_nn/model/group_message_item_entity.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/type/MessageType.dart';
import 'package:premades_nn/type/VoiceStatusType.dart';
import 'package:premades_nn/utils/AudioPlayerUtil.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/Strings.dart';

import 'image_detail_screen.dart';

///聊天页面单条数据界面 list--item
///

class GroupChatMessage extends StatefulWidget {
  final String avatar;

  final GroupMessageItemEntity messageItem;

  final AnimationController animationController;

  final Function callback;

  GroupChatMessage(
      {this.animationController, this.messageItem, this.avatar, this.callback});

  @override
  _GroupChatMessageState createState() => _GroupChatMessageState();
}

class _GroupChatMessageState extends State<GroupChatMessage> {
  Alignment _alignment; //对齐方式--用来控制item的左对齐（其他用户）还是右对齐（用户本身）

  TextEditingController _inputController = TextEditingController();

  double screenWidth; //屏幕宽度
  double screenHeight; //屏幕高度
  double globlePositionX; //点击位置x偏移量
  double globlePositionY; //点击位置y偏移量
  double widgetHeight; //控件高度
  double widgetY; //控件y偏移量

  BuildContext _context;

  bool _isPlay = false; //语音消息是否正在播放

  bool _isTranslate = false;
  String _translateContent = "";

  @override
  Widget build(BuildContext context) {
    _context = context;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    Widget child;
    if (widget.messageItem.fromNnid == Constants.userInfo.nnId &&
        widget.messageItem.messageType != 5) {
      _alignment = Alignment.centerRight;
      child = send();
    } else {
      _alignment = Alignment.centerLeft;
      child = received();
    }

    if (widget.animationController == null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: child,
      );
    } else {
      return ScaleTransition(
          alignment: _alignment,
          scale: widget.animationController,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: child,
          ));
    }
  }

  ///接收方
  Widget received() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        avatarBox(widget.messageItem.fromAvatar),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.messageItem.fromNickname,
              style: TextStyle(
                  color: ColorUtil.grey, fontSize: ScreenUtil().setSp(12)),
            ),
            messageBox('left'),
          ],
        ),
      ],
    );
  }

  ///发送方
  Widget send() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        messageBox('right'),
        avatarBox(Constants.userInfo.avatar),
      ],
    );
  }

  ///消息组件
  Widget messageBox(direction) {
    _inputController.text = widget.messageItem.content;

    if (widget.messageItem.messageType == MessageType.VOICE_CALL) {
      //语音通话
      return voiceCallItem(direction);
    } else if (widget.messageItem.messageType == MessageType.IMAGE) {
      //图片
      return imageItem(direction);
    } else if (widget.messageItem.messageType == MessageType.RECORD) {
      //语音消息
      return recordItem(direction);
    } else {
      //文本信息
      return textItem(direction);
    }
  }

  /// 语音通话
  Widget voiceCallItem(String type) {
    //内容文字显示
    String callStatusConent = "";
    switch (widget.messageItem.extra.callStatus) {
      case VoiceStatusType.CANCAL:
        callStatusConent = "未接听，点击重拨";
        break;
      case VoiceStatusType.REFUSED:
        if (type == "left") {
          callStatusConent = "未接听，点击重拨";
        } else {
          callStatusConent = "对方已拒绝";
        }
        break;
      case VoiceStatusType.HANG_UP:
        String timeContent = "";
        int minute = (widget.messageItem.extra.callDuration / 60).floor();
        int second = widget.messageItem.extra.callDuration - minute * 60;
        if (minute == 0) {
          timeContent = "00:";
        } else if (minute < 10 && minute > 0) {
          timeContent = "0$minute:";
        } else {
          timeContent = "$minute:";
        }
        if (second == 0) {
          timeContent += "00";
        } else if (second < 10 && second > 0) {
          timeContent += "0$second";
        } else {
          timeContent += "$second";
        }
        callStatusConent = "通话时长 $timeContent";
        break;
      case VoiceStatusType.REPONSE_TIME_OUT:
        if (type == "left") {
          callStatusConent = "未接听，点击重拨";
        } else {
          callStatusConent = "对方未接听";
        }
        break;
    }

    EdgeInsetsGeometry padding;
    EdgeInsetsGeometry margin;
    String imageUrl = "";
    Rect rect;
    if (type == "left") {
      padding = EdgeInsets.fromLTRB(15, 10, 10, 10);
      margin = EdgeInsets.only(right: 50, bottom: 10);
      imageUrl = "images/bubble_others_default.png";
      rect = Rect.fromLTWH(15, 30, 2, 2);
    } else {
      padding = EdgeInsets.fromLTRB(10, 10, 15, 10);
      margin = EdgeInsets.only(left: 50, bottom: 10);
      imageUrl = "images/bubble_myself_default.png";
      rect = Rect.fromLTWH(8, 30, 2, 2);
    }

    return InkWell(
      onTap: () {
        if (widget.callback != null) {
          widget.callback();
        }
      },
      child: Container(
        constraints: BoxConstraints(minHeight: 30, maxWidth: ScreenUtil().setWidth(275)),
        padding: padding,
        decoration: BoxDecoration(
          image: DecorationImage(
              centerSlice: rect,
              image: AssetImage(imageUrl),
              fit: BoxFit.fill),
        ),
        margin: margin,
        child: Row(
          children: <Widget>[
            Image.asset(
              "images/icon_voice_phone.png",
              width: ScreenUtil().setWidth(16),
              fit: BoxFit.fitWidth,
            ),
            Container(
              margin: EdgeInsets.only(left: 5),
              child: Text(
                callStatusConent,
                style: TextStyle(
                    color: ColorUtil.black, fontSize: ScreenUtil().setSp(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///  图片组件
  Widget imageItem(String type) {
    double maxSize = (screenWidth - 10 - 15 - 40 - 50) / 2;

    //TODO 图片的默认大小控制----用来解决消息页面加载变动
    double imageWidth = 0;
    double imageHeight = 0;

    if (widget.messageItem.extra.imageWidth != null &&
        widget.messageItem.extra.imageHeight != null) {
      if (widget.messageItem.extra.imageWidth <= maxSize &&
          widget.messageItem.extra.imageHeight <= maxSize) {
        imageWidth = widget.messageItem.extra.imageWidth.ceilToDouble();
        imageHeight = widget.messageItem.extra.imageHeight.ceilToDouble();
      } else if (widget.messageItem.extra.imageWidth <= maxSize &&
          widget.messageItem.extra.imageHeight > maxSize) {
        imageWidth = maxSize /
            widget.messageItem.extra.imageHeight *
            widget.messageItem.extra.imageWidth;
        imageHeight = maxSize;
      } else if (widget.messageItem.extra.imageWidth > maxSize &&
          widget.messageItem.extra.imageHeight <= maxSize) {
        imageWidth = maxSize;
        imageHeight = maxSize /
            widget.messageItem.extra.imageWidth *
            widget.messageItem.extra.imageHeight;
      } else if (widget.messageItem.extra.imageWidth > maxSize &&
          widget.messageItem.extra.imageHeight > maxSize) {
        if (widget.messageItem.extra.imageWidth >=
            widget.messageItem.extra.imageHeight) {
          imageWidth = maxSize;
          imageHeight = maxSize /
              widget.messageItem.extra.imageWidth *
              widget.messageItem.extra.imageHeight;
        } else {
          imageWidth = maxSize /
              widget.messageItem.extra.imageHeight *
              widget.messageItem.extra.imageWidth;
          imageHeight = maxSize;
        }
      }

      if (imageWidth < 40) {
        imageWidth = 40;
      } else {
        imageWidth = imageWidth.floor().ceilToDouble();
      }
      if (imageHeight < 40) {
        imageHeight = 40;
      } else {
        imageHeight = imageHeight.floor().ceilToDouble();
      }
    } else {
      imageWidth = 40;
      imageHeight = 40;
    }

    EdgeInsetsGeometry edgeInsets;
    if (type == "left") {
      edgeInsets = EdgeInsets.only(right: 50, bottom: 10);
    } else {
      edgeInsets = EdgeInsets.only(left: 50, bottom: 10);
    }
    return InkWell(
      onTap: () {
        Navigator.push(_context, MaterialPageRoute(builder: (context) {
          return ImageDetailScreen(
              url: widget.messageItem.content,
              imageWidth: widget.messageItem.extra.imageWidth,
              imageHeight: widget.messageItem.extra.imageHeight);
        }));
      },
      child: Container(
        constraints: BoxConstraints(minHeight: ScreenUtil().setHeight(42), minWidth: ScreenUtil().setWidth(42), maxWidth: ScreenUtil().setWidth(275)),
        decoration:
            BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5))),
        margin: edgeInsets,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
//              constraints: BoxConstraints(
//                  maxWidth: maxSize,
//                  maxHeight: maxSize,
//                  minWidth: 40,
//                  minHeight: 40),
              child: Image.network(
                widget.messageItem.content +
                    "?x-oss-process=image/resize,m_fill,h_${imageHeight.floor()},w_${imageWidth.floor()},limit_0",
                fit: BoxFit.fill,
                width: imageWidth,
                height: imageHeight,
              ),
            ),
//                Offstage(
//                  offstage: widget.messageItem.sendType == SendType.SEND_SUCCESS,
//                  child: Container(
//                    width: 40,
//                    height: 40,
//                    color: Colors.black.withOpacity(0.5),
//                    padding: EdgeInsets.all(10),
//                    child: CircularProgressIndicator(
//                      strokeWidth: 2,
//                      backgroundColor: Colors.orange,
//                    ),
//                  ),
//                ),
          ],
        ),
      ),
    );
  }

  /// 语音消息
  Widget recordItem(String type) {
    //最短60 ， 时长为60s后
    int duration = widget.messageItem.extra.voiceDuration;
    if (duration == null) {
      duration = 0;
    }
    double maxSize = screenWidth - 10 - 15 - 40 - 50;
    double minSize = 60;

    double tempWidth = (maxSize - minSize) / 45 * duration;
    double itemWidth;
    if (tempWidth > maxSize) {
      itemWidth = maxSize;
    } else if (tempWidth < 80) {
      itemWidth = 80;
    } else {
      itemWidth = tempWidth;
    }

    int minyte = (duration / 60).floor();
    int second = duration - minyte * 60;
    String timeStr;
    if (minyte == 0) {
      timeStr = "$second\"";
    } else {
      timeStr = "$minyte'$second\"";
    }

    Image image;

    if (_isPlay) {
      image = Image.asset(
        "images/icon_play.png",
        width: ScreenUtil().setWidth(16),
        fit: BoxFit.fitWidth,
      );
    } else {
      image = Image.asset(
        "images/icon_pause.png",
        width: ScreenUtil().setWidth(16),
        fit: BoxFit.fitWidth,
      );
    }

    EdgeInsetsGeometry padding;
    EdgeInsetsGeometry margin;
    String imageUrl = "";
    Rect rect;
    if (type == "left") {
      padding = EdgeInsets.fromLTRB(15, 10, 10, 10);
      margin = EdgeInsets.only(right: 50, bottom: 10);
      imageUrl = "images/bubble_others_default.png";
      rect = Rect.fromLTWH(15, 30, 2, 2);
    } else {
      padding = EdgeInsets.fromLTRB(10, 10, 15, 10);
      margin = EdgeInsets.only(left: 50, bottom: 10);
      imageUrl = "images/bubble_myself_default.png";
      rect = Rect.fromLTWH(8, 30, 2, 2);
    }

    Widget translate;
    if (_isTranslate) {
      translate = Container(
        margin: EdgeInsets.only(top: 5),
        child: Text(_translateContent, style: TextStyle(color: ColorUtil.black)),
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: ColorUtil.black, width: 1))),
      );
    } else {
      translate = Center();
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isPlay = !_isPlay;
        });

        if (_isPlay) {
          AudioPlayerUtil.instance.playAudio(widget.messageItem.content, () {
            setState(() {
              _isPlay = false;
            });
          });
        } else {
          AudioPlayerUtil.instance.stopAudio();
        }
      },
      onLongPress: () {
        String type;
        double left = globlePositionX - 100 / 2;
        double top;
        if (globlePositionY <
            50 + MediaQueryData.fromWindow(window).padding.top + 60) {
          type = "bottom";
          top = widgetY + widgetHeight - 10;
        } else {
          type = "top";
          top = widgetY + 10 - 35 - 10; //40：菜单高度  15：三角高度  消息控件padding高度
        }

        Navigator.push(
            context,
            PopRoute(
                child: PopupWindow(
                    type: type,
                    pointX: globlePositionX,
                    left: left,
                    top: top,
                    callback: () {
                      Map formData = {"voice_url": widget.messageItem.content};
                      request("post", allUrl["voiceToWord"], formData)
                          .then((result) {
                        if (result["code"] == 0 && result["data"] != null) {
                          setState(() {
                            _isTranslate = true;
                            _translateContent = result["data"]["text"];
                          });
                        } else {
                          toast(Strings.transferTextFail);
                        }
                      });
                    })));
      },
      onLongPressStart: (LongPressStartDetails details) {
        RenderObject renderObject = context.findRenderObject();
        var vector3 = renderObject.getTransformTo(null)?.getTranslation();
        globlePositionX = details.globalPosition.dx - 15 / 2; //
        globlePositionY = details.globalPosition.dy;
        widgetHeight = context.size.height;
        widgetY = vector3[1];
      },
      child: Container(
        width: itemWidth,
        constraints: BoxConstraints(minHeight: ScreenUtil().setHeight(42), minWidth: ScreenUtil().setWidth(42), maxWidth: ScreenUtil().setWidth(275)),
        padding: padding,
        decoration: BoxDecoration(
          image: DecorationImage(
              centerSlice: rect,
              image: AssetImage(imageUrl),
              fit: BoxFit.fill),
        ),
        margin: margin,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                image,
                Expanded(
                  child: Container(
                    constraints:
                        BoxConstraints(minWidth: 60, maxWidth: maxSize),
                    child: Text(""),
                  ),
                ),
                Container(
                  child: Text(
                    timeStr,
                    style: TextStyle(
                        color: ColorUtil.black, fontSize: ScreenUtil().setSp(15)),
                  ),
                ),
              ],
            ),
            translate,
          ],
        ),
      ),
    );
  }

  ///文字消息
  Widget textItem(String type) {
    EdgeInsetsGeometry padding;
    EdgeInsetsGeometry margin;
    String imageUrl = "";
    Rect rect;
    if (type == "left") {
      padding = EdgeInsets.fromLTRB(15, 10, 10, 10);
      margin = EdgeInsets.only(right: 50, bottom: 10);
      imageUrl = "images/bubble_others_default.png";
      rect = Rect.fromLTWH(15, 30, 2, 2);
    } else {
      padding = EdgeInsets.fromLTRB(10, 10, 15, 10);
      margin = EdgeInsets.only(left: 50, bottom: 10);
      imageUrl = "images/bubble_myself_default.png";
      rect = Rect.fromLTWH(8, 30, 2, 2);
    }
    return Container(
      child: ExtendedText(
        widget.messageItem.content,
        style: TextStyle(color: ColorUtil.black, fontSize: ScreenUtil().setSp(15)),
        specialTextSpanBuilder: MySpecialTextSpanBuilder(),
      ),
      constraints: BoxConstraints(minHeight: ScreenUtil().setHeight(42), minWidth: ScreenUtil().setWidth(42), maxWidth: ScreenUtil().setWidth(275)),
      padding: padding,
      decoration: BoxDecoration(
        image: DecorationImage(
            centerSlice: rect,
            image: AssetImage(imageUrl),
            fit: BoxFit.fill),
      ),
      margin: margin,
    );
  }

  ///头像组件
  Widget avatarBox(String headImageUrl) {
    return Container(
        margin: EdgeInsets.only(left: ScreenUtil().setWidth(5), right: ScreenUtil().setWidth(5)),
        width: ScreenUtil().setWidth(40),
        child: AspectRatio(
          aspectRatio: 1,
          child: ClipOval(
            child: Image.network(
              headImageUrl,
            ),
          ),
        ));
  }
}

///语音消息 长按菜单
class PopupWindow extends StatelessWidget {
  final String type;

  final double left;

  final double top;

  final double pointX;

  final Function callback;

  final double widgetWidth = 80;
  final double widgetHeight = 35;

  final double triangleHeight = 10;
  final double triangleWidth = 15;

  PopupWindow({this.left, this.top, this.pointX, this.type, this.callback});

  @override
  Widget build(BuildContext context) {
    double triangleLeft; //三角left偏移量
    double triangleTop; //三角top偏移量
    if (type == "top") {
      triangleLeft = pointX;
      triangleTop = top + widgetHeight;
    } else if (type == "bottom") {
      triangleLeft = pointX;
      triangleTop = top - 10;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: left,
              top: top,
              child: Container(
                child: Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        if (callback != null) {
                          callback();
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: widgetWidth,
                        height: widgetHeight,
                        child: Text(
                          "转文本",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.black),
              ),
            ),
            Positioned(
              left: triangleLeft,
              top: triangleTop,
              child: ClipPath(
                clipper: Triangle(type: type),
                child: Container(
                  width: triangleWidth,
                  height: triangleHeight,
                  color: Colors.black,
                  child: null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///弹出菜单路由
class PopRoute extends PopupRoute {
  final Duration _duration = Duration(milliseconds: 100);
  Widget child;

  PopRoute({@required this.child});

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Duration get transitionDuration => _duration;
}

///三角图片绘制
class Triangle extends CustomClipper<Path> {
  String type;

  Triangle({this.type});

  @override
  Path getClip(Size size) {
    var path = Path();
    double w = size.width;
    double h = size.height;
    if (type == "top") {
      path.lineTo(w, 0);
      path.lineTo(w / 2, h);
      path.lineTo(0, 0);
    } else if (type == "bottom") {
      path.moveTo(w / 2, 0);
      path.lineTo(w, h);
      path.lineTo(0, h);
      path.lineTo(w / 2, 0);
    }
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
