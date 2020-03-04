import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';
import '../../../components/bottom_sheet.dart';
import '../../../provide/storeData.dart';
import '../../../service/service.dart';
import '../../../service/service_url.dart';

class TypeList extends StatefulWidget {
  final typeList;
  final typeChoose;
  final callBack;
  final firstClick;
  final typeChangeCallBack;
  TypeList({ this.typeList, this.typeChoose, this.firstClick, this.callBack, this.typeChangeCallBack });
  _TypeListState createState() => _TypeListState();
}

class _TypeListState extends State<TypeList>{
  var _clickIndex = 0;


  void _chooseType(data) {
    var myData = data;
    myData['page'] = 1;
    myData['limit'] = 15;
    widget.callBack(myData);
  }

  @override
  void initState() {
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if(widget.firstClick == 0) {
    //   setState(() {
    //     _clickIndex = widget.firstClick;
    //   });
    // }
    if(Provide.value<StoreData>(context).typeIndex != null) {
      for(int i = 0; i < widget.typeList.length; i += 1) {
        if(widget.typeList[i]['game_id'] == Provide.value<StoreData>(context).typeIndex) {

          setState(() {
            _clickIndex = i;
          });
        }
      }
      Provide.value<StoreData>(context).changeTypeIndex(null);
    }
    return SliverPersistentHeader(
      pinned: true, // 是否固定在顶部
      floating: true,
      delegate: _SliverAppBarDelegate(
        minHeight: ScreenUtil().setHeight(50.0), //收起的高度
        maxHeight: ScreenUtil().setHeight(50.0), //展开的最大高度
        child: Container(
          width: ScreenUtil().setWidth(375.0),
          height: ScreenUtil().setHeight(50.0),
          color: Colors.white,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  height: ScreenUtil().setHeight(50.0),
                  padding: EdgeInsets.only(
                    top: ScreenUtil().setHeight(10.0),
                    bottom: ScreenUtil().setHeight(5.0),
                    left: ScreenUtil().setWidth(5.0),
                    right: ScreenUtil().setWidth(5.0),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.typeList.length,
                    itemBuilder: (context, index){
                      return _typeItem(index);
                    },
                  )
                ),
              ),
              InkWell(
                onTap: () {
                  // 选择类型弹窗
                  bottomSheet(context, '筛选', widget.typeChoose, _chooseType);
                },
                child: Container(
                  width: ScreenUtil().setWidth(45.0),
                  height: ScreenUtil().setHeight(50.0),
                  color: Color.fromRGBO(248, 248, 248, 1.0),
                  alignment: Alignment.center,
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 36.0,
                        height: 36.0,
                        child: Image.asset('images/more.png', fit: BoxFit.cover),
                      )
                    ],
                  )
                )
              )
            ],
          ),
        )
      ),
    );
  }

  Widget _typeItem(int index) {
    bool isClick = index == _clickIndex;
    
    return Provide<StoreData>(
      builder: (context, child, data) {
        if(data.addCardItem != null) {

        }
        return Row(
          children: <Widget>[
            InkWell(
              onTap: () {
                setState((){
                  _clickIndex = index;
                  widget.typeChangeCallBack(widget.typeList[index]['game_id']);
                });
                Map data = {
                  "game_id": widget.typeList[index]['game_id'],
                  "area_id": null,
                  "level_id": null,
                  "mode_id": null,
                  "page": 1,
                  "limit": 15
                };
                widget.callBack(data);
              },
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 4.0),
                      child: Text(widget.typeList[index]['game_name'], style: TextStyle(
                          color: isClick ? Colors.black : Color.fromRGBO(102,102,102, 1.0),
                          fontSize: isClick ? ScreenUtil().setSp(17.0) : ScreenUtil().setSp(16.0),
                          fontWeight: isClick ? FontWeight.w700 : FontWeight.w300,
                        )),
                    ),
                  ),
                  Container(
                    width: 25.0,
                    height: 3.0,
                    decoration: BoxDecoration(
                      color: isClick ? Colors.black : Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                    ),
                  )
                ],
              )
            ),
            SizedBox(width: ScreenUtil().setWidth(5.0),),
          ],
        );
      }
    );
  }

}


class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}