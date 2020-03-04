import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../components/image_view.dart';
import './power_sheet.dart';


Widget messageItem(item, room_no, context, callBack) {
  switch (item['command_id']) {
    case 500000:
      return Container(
        margin: EdgeInsets.only(top: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(15.0, 7.0, 15.0, 7.0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(35, 243, 173, 0.4),
                borderRadius: BorderRadius.circular(13) 
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: (){
                      powerSheet(context, item['nn_id'], room_no);
                    },
                    child: Text(item['name'], style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                    ),),
                  ),
                  SizedBox(width: 5.0,),
                  Text('进入了频道', style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.0,
                  ),),
                ],
              ),
            )
          ],
          
        ),
      );
    case 500002:
      return Container(
        margin: EdgeInsets.only(top: 22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: (){
                powerSheet(context, item['nn_id'], room_no);
              },
              child: Text(item['name'], style: TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.7),
                fontSize: 10.0,
              ),),
            ),
            SizedBox(height: 8.0,),
            item['message_type'] == 1 ? roomContent(item['content'])
            :
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) {
                    return ImageView(img: item['content']);
                  }
                );
              },
              child: Container(
                alignment: Alignment.topLeft,
                constraints: BoxConstraints(
                  maxWidth: ScreenUtil().setWidth(180.0),
                  maxHeight: ScreenUtil().setHeight(180.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    Image.network(item['content'],)
                  ],
                ),
              )
            )
          ],
        ),
      );
    default:
  }
}

Widget isEmoji(str) {
  return Text('fff');
}

Widget roomContent(val) {
  var str1 = [];
  if(val.contains("<em>")) {
    str1 = val.split("<em>");

    if(str1.length > 0) {
      return Container(
        padding: EdgeInsets.fromLTRB(13.0, 8.0, 13.0, 8.0),
        child: Wrap(
          //水平间距
          spacing: ScreenUtil().setWidth(1.0),
          //垂直间距
          runSpacing: ScreenUtil().setHeight(1.0),
          //对齐方式
          alignment: WrapAlignment.start,
          children: emojiItem(str1),
        ),
        // Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: emojiItem(str1),
        // ),
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.1),
          borderRadius: BorderRadius.all(Radius.circular(5.0))
        ),
      );
    }
  } else {
    return Container(
      padding: EdgeInsets.fromLTRB(13.0, 4.0, 13.0, 4.0),
      child: Text(val, style: TextStyle(
          color: Colors.white,
          fontSize: 12.0,
        ),
      ),
      decoration: BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 0.1),
        borderRadius: BorderRadius.all(Radius.circular(5.0))
      ),
    );
  }
}

List<Widget> emojiItem(list) { /// e10304032</em>ddddddd
  List<Widget> data = [];
  list.forEach((res){
    data.add(
      oneItem(res)
    );
  });
  return data;
}

Widget oneItem(val) {
  if(val.contains("</em>")) {
    if(val.endsWith("</em>")) { /// 是否以</em>结尾，如果是后面就没有其他文本了
      return Container(
        width: 20.0,
        height: 20.0,
        child: Image.asset('images/emoji/${val.replaceAll("</em>","")}.png')
      );
    } else {
      var newList = val.split("</em>");
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 20.0,
            height: 20.0,
            child: Image.asset('images/emoji/${newList[0]}.png'),
          ),
          Text(newList[1], style: TextStyle(
              color: Colors.white,
              fontSize: 12.0,
            )
          )
        ],
      );
    }
  } else {
    return Text(val, style: TextStyle(
        color: Colors.white,
        fontSize: 12.0,
      )
    );
  }
}

