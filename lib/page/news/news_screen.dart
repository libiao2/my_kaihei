import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_custom_bottom_tab_bar/eachtab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/page/news/group_member_operation_screen.dart';
import 'package:premades_nn/type/GroupMemberOperationType.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Strings.dart';
import 'group_list.dart';
import 'message_screen.dart';
import 'contact_list.dart';
import 'good_friend_add.dart';

class NewsScreen extends StatefulWidget {

  @override
  _NewsScreenState createState() => _NewsScreenState();

}

class _NewsScreenState extends State<NewsScreen> with SingleTickerProviderStateMixin {
  final tabs = ["消息", "好友", "群聊"];

  TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, initialIndex: 0, length: tabs.length);
    _tabController.addListener(() {
      setState(() => _selectedIndex = _tabController.index);
      print("liucheng-> ${_tabController.indexIsChanging}");
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: MediaQueryData.fromWindow(window).padding.top),
            height: ScreenUtil().setHeight(50),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TabBar(
                    isScrollable: false,
                    controller: _tabController,
                    indicatorColor: Colors.transparent,
                    labelPadding: EdgeInsets.all(0),
                    unselectedLabelColor: Colors.black,
                    tabs: <Widget>[
                      EachTab(
                          child: Container(
                            alignment: Alignment.center,
                            height: ScreenUtil().setHeight(50),
                            child: Text(tabs[0], style: TextStyle(fontSize: _selectedIndex == 0?ScreenUtil().setSp(18):ScreenUtil().setSp(16),
                                color: _selectedIndex == 0?ColorUtil.black:ColorUtil.htmlGrey, fontWeight: _selectedIndex == 0?FontWeight.w700:FontWeight.w300),),
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(
                                    width: 4,
                                    color: _selectedIndex == 0?ColorUtil.black:Colors.transparent
                                ))
                            ),
                          )
                      ),
                      EachTab(
                          child: Container(
                            alignment: Alignment.center,
                            height: ScreenUtil().setHeight(50),
                            child: Text(tabs[1], style: TextStyle(fontSize: _selectedIndex == 1?ScreenUtil().setSp(18):ScreenUtil().setSp(16),
                                color: _selectedIndex == 1?ColorUtil.black:ColorUtil.htmlGrey, fontWeight: _selectedIndex == 1?FontWeight.w700:FontWeight.w300),),
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(
                                    width: 4,
                                    color: _selectedIndex == 1?ColorUtil.black:Colors.transparent
                                ))
                            ),
                          )
                      ),
                      EachTab(
                          child: Container(
                            alignment: Alignment.center,
                            height: ScreenUtil().setHeight(50),
                            child: Text(tabs[2], style: TextStyle(fontSize: _selectedIndex == 2?ScreenUtil().setSp(18):ScreenUtil().setSp(16),
                                color: _selectedIndex == 2?ColorUtil.black:ColorUtil.htmlGrey, fontWeight: _selectedIndex == 2?FontWeight.w700:FontWeight.w300),),
                            decoration: BoxDecoration(
                                border: Border(bottom: BorderSide(
                                    width: 4,
                                    color: _selectedIndex == 2?ColorUtil.black:Colors.transparent
                                ))
                            ),
                          )
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  offset: Offset(0, ScreenUtil().setHeight(50)),
                  child: Container(
                    margin: EdgeInsets.only(
                        right: ScreenUtil().setWidth(15),
                        left: ScreenUtil().setWidth(140)),
                    padding: EdgeInsets.all(ScreenUtil().setWidth(5)),
                    alignment: Alignment.center,
                    child: Container(
                      width: ScreenUtil().setWidth(12),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.asset(
                          "images/icon_add.png",
                        ),
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          //设置阴影
                          BoxShadow(
                            offset: Offset(0, 5),
                            color: ColorUtil.shadow, //阴影颜色
                            blurRadius: 5, //阴影大小
                          ),
                        ],
                        gradient: LinearGradient(colors: [
                          ColorUtil.btnStartColor,
                          ColorUtil.btnEndColor,
                        ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      ),
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        //设置阴影
                        BoxShadow(
                          offset: Offset(0, 5),
                          color: ColorUtil.shadow, //阴影颜色
                          blurRadius: 5, //阴影大小
                        ),
                      ],
                      gradient: LinearGradient(colors: [
                        ColorUtil.btnStartColor,
                        ColorUtil.btnEndColor,
                      ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    ),
                  ),
                  itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                    PopupMenuItem<String>(
                      value: "groupChat",
                      child: Text(Strings.createGroupChat),
                    ),
                    PopupMenuItem<String>(
                      value: "addFriend",
                      child: Text(Strings.addFriend),
                    ),
                  ],
                  onSelected: (action) {
                    switch (action) {
                      case "groupChat":
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return GroupMemberOperationScreen(
                                  type: GroupMemberOperationType.createGroup);
                            }));
                        break;
                      case "addFriend":
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                              return GoodFriendAdd();
                            }));
                        break;
                    }
                  },
                )
              ],
            )
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                MessageScreen(),
                ContactListRoute(),
                GroupListScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 标签栏
  Widget getTabBar() {
    return Container(
        child: TabBar(
      indicatorWeight: 3,
      indicatorColor: ColorUtil.black,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
          fontSize: ScreenUtil().setSp(18), fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(
        fontSize: ScreenUtil().setSp(16),
      ),
      tabs: tabs.map((t) {
        return Tab(
          child: Text(
            t,
            style: TextStyle(color: Colors.black),
          ),
        );
      }).toList(),
    ));
  }

  // 页面
  Widget getTabBarPages() {
    return Container(
        child: TabBarView(
      children: <Widget>[
        MessageScreen(),
        ContactListRoute(),
        GroupListScreen(),
      ],
    ));
  }
}
