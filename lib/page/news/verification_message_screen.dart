import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/SocketHelper.dart';

class VerificationMessageScreen extends StatefulWidget {

  int nnId;

  int friendFrom = 1;//好友来源 1搜索  2频道

  VerificationMessageScreen({Key key, this.nnId, this.friendFrom}) : super(key: key);

  @override
  _VerificationMessageState createState() => _VerificationMessageState();
}

class _VerificationMessageState extends State<VerificationMessageScreen> {
  TextEditingController _controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("身份验证"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        actions: <Widget>[
          GestureDetector(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                '提交',
                style: TextStyle(color: Colors.black),
              ),
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            ),
            onTap: _onSubmitClick,
          ),
        ],
      ),
      body: Column(children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border:
                Border.all(width: 5, color: Color.fromRGBO(242, 242, 242, 1.0)),
          ),
        ),
        Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(5),
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: TextField(
              autofocus: false,
              controller: _controller,
              cursorColor: ColorUtil.black,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "告诉对方您的信息，以便于通过添加",
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ))),
        )
      ]),
    );
  }

  void _onSubmitClick() {
    String verificationMessage = _controller.text;
    if (verificationMessage == null || verificationMessage == ""){
      Fluttertoast.showToast(
          msg: "验证信息不能为空！",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }

    SocketHelper.addFriend(widget.nnId, widget.friendFrom, verificationMessage, 1);

    Fluttertoast.showToast(
        msg: "好友请求已发送！",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0
    );

  }
}
