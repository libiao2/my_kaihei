import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:premades_nn/model/search_user_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserList extends StatefulWidget {
  final List<SearchUser> userData;
  final Function userItemClick;

  const UserList({Key key, this.userData, this.userItemClick})
      : super(key: key);

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  @override
  Widget build(BuildContext context) {
//    return Container(
//      child: SingleChildScrollView(
//          child: Column(
//        children: user(),
//      )),
//    );

    return ListView.builder(
        shrinkWrap: true,
        itemCount: widget.userData.length,
        itemBuilder: (BuildContext context, int index) {
          return searchUserItem(widget.userData[index]);
        },
      );
  }

  // 列表
  List<Widget> user() {
    List<Widget> list = [];
    widget.userData.forEach((item) {
      list.add(userItem(item));
    });
    return list;
  }

  Widget searchUserItem(SearchUser searchUser) {
    return ListTile(
      leading: Container(
          child: Image.network(searchUser.avatar,),
          width: 60,
          height: 60,
          color: Colors.grey),
      trailing: new Ink(
        decoration: new BoxDecoration(
          color: Color.fromRGBO(170, 170, 170, 1),
          borderRadius: new BorderRadius.all(new Radius.circular(15.0)),
        ),
        child: new InkWell(
          borderRadius: new BorderRadius.circular(15.0),
          onTap: () {
            addFriend(searchUser);
          },
          child: new Container(
            //设置child 居中
            padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
            height: 30,
            alignment: Alignment(0, 0),
            child: Text(
              "添加",
              style: TextStyle(color: Colors.white, fontSize: 14.0),
            ),
          ),
        ),
      ),
      title: Text(searchUser.nickname),
      onTap: () {
        _userItemClick(searchUser);
      },
    );
  }


  // 单项
  Widget userItem(SearchUser item) {
    return Container(
      margin: EdgeInsets.only(right: 15),
      child: InkWell(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                avatar(item),
                Center(
                  child: Text(item.nickname),
                ),
              ],
            ),
            new Ink(
              decoration: new BoxDecoration(
                color: Color.fromRGBO(170, 170, 170, 1),
                borderRadius: new BorderRadius.all(new Radius.circular(15.0)),
              ),
              child: new InkWell(
                borderRadius: new BorderRadius.circular(15.0),
                onTap: () {
                  addFriend(item);
                },
                child: new Container(
                  //设置child 居中
                  padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                  height: 30,
                  alignment: Alignment(0, 0),
                  child: Text(
                    "添加",
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ),
              ),
            )
          ],
        ),
        onTap: () {
          _userItemClick(item);
        },
      ),
      height: ScreenUtil().setHeight(112.0),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(242, 242, 242, 1),
                  width: 1.0,
                  style: BorderStyle.solid))),
    );
  }

  // 头像
  Widget avatar(SearchUser item) {
    return Container(
      child: CircleAvatar(
        radius: ScreenUtil().setWidth(40),
        backgroundImage: NetworkImage(item.avatar),
      ),
      margin: EdgeInsets.fromLTRB(10, 0, 20, 0),
    );
  }

  _userItemClick(SearchUser item) {
    if (widget.userItemClick != null) widget.userItemClick(item);
  }

  Future addFriend(SearchUser item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String nnid = prefs.getString("nnId");
    if (nnid == item.nnId.toString()) {
      Fluttertoast.showToast(
          msg: '不能添加自己为好友！',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
  }
}
