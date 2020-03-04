import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../provide/storeData.dart';
import './power_sheet.dart';

class RoomMembers extends StatelessWidget{
  final room_no;
  final speakCallback;
  RoomMembers({ this.room_no, this.speakCallback });

  var no_write = 'images/no_write.png';
  var no_speak = 'images/no_speak.png';
  var no_all = 'images/no_all.png';

  @override
  Widget build(BuildContext context) {
    return Provide<StoreData>(
      builder: (context, child, data){
        int peopleNum = data.room_info['limit_number'];
        Map userInfo = data.userInfo;
        return Container(
          child: Wrap(
            //水平间距
            spacing: ScreenUtil().setWidth(10.0),
            //垂直间距
            runSpacing: ScreenUtil().setHeight(15.0),
            //对齐方式
            alignment: WrapAlignment.start,
            children: _onePeople(data.show_room_user, peopleNum, userInfo, context),
          )
        );
      }
    );
  }

  List<Widget> _onePeople(peopleList, peopleNum, userInfo, context) {
    List myList = [];
    if(peopleList == null) {
      int len = peopleNum - 1;
      for (int i = 0; i < len; i++) {
        myList.add(i.toString());
      }
    } else {
      if(peopleList.length < peopleNum) {
        for(int i = 0; i < peopleList.length; i++) {
          myList.add(peopleList[i]);
        }
        int len = peopleNum - peopleList.length - 1;
        for (int i = 0; i < len; i++) {
          myList.add(i.toString());
        }
      } else {
        for(int i = 0; i < peopleList.length; i++) {
          myList.add(peopleList[i]);
        }
    }
    }
    List<Widget> nameList = [];

    var img = '';
    
    myList.forEach((val){
      if(!(val is String)) {
        if(userInfo['nn_id'] == val['nn_id']) {
          if(val['isClosedWheat']) {
            this.speakCallback(true);
          } else {
            this.speakCallback(false);
          }
        }
        if(!val['isTypeWrite'] && val['isClosedWheat']) { // 禁止打字
          img = no_write;
        }
        if(val['isTypeWrite'] && !val['isClosedWheat']) {  // 禁止说话
          img = no_speak;
          
        }
        if(!val['isTypeWrite'] && !val['isClosedWheat']) {  // 
          img = no_all;
        }
        if(val['isTypeWrite'] && val['isClosedWheat']) {
          img = '';
        }
      }
      nameList.add(
        val is String ?
        Column(
          children: <Widget>[
            Container(
              width: 60,
              height: 60,
              decoration: ShapeDecoration(
                shape: CircleBorder(),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('images/room_no_people.png')
                )
              )
            ),
            // SizedBox(height: 10.0,)
          ],
        )
        :
        InkWell(
          onTap: (){
            powerSheet(context, val['nn_id'], this.room_no);
          },
          child: Column(
            children: <Widget>[
              Stack(
                alignment: const FractionalOffset(0.8, 0.85),
                children: <Widget>[
                  // Container(
                  //   width: 60,
                  //   height: 60,
                  //   decoration: ShapeDecoration(
                  //     shape: CircleBorder(),
                  //     image: DecorationImage(
                  //       fit: BoxFit.cover,
                  //       image: NetworkImage(val['avatar'])
                  //     )
                  //   )
                  // ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1.0,
                        color: val['is_drop_line'] ? Color.fromRGBO(35,243,173,1) : Colors.transparent
                      ),
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(val['avatar']),
                        fit: BoxFit.cover
                      )
                    )
                  ),
                  Container(
                    width: 15.0,
                    height: 15.0,
                    child: Image.asset(img)
                  ),
                  Offstage(
                    offstage: !val['is_drop_line'],
                    child: Stack(
                      alignment: const FractionalOffset(0.5, 0.5),
                      children: <Widget>[
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                            shape: BoxShape.circle,
                          )
                        ),
                        Container(
                          width: 20.0,
                          height: 20.0,
                          child: Image.asset('images/diaoxian.png')
                        ),
                      ],
                    )
                  )
                ],
              ),
              SizedBox(height: 10.0,),
              Container(
                alignment: Alignment.center,
                width: 60.0,
                child: Text(val['nickname'], 
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.0,
                )),
              )
            ],
          )
        )
      );
    });
    return nameList;
  }
}