import 'package:flutter/material.dart';
import '../../../utils/Constants.dart';

Widget sendEmoji(callBack) {

  return Container(
      color: Color.fromRGBO(242, 242, 242, 1),
      height: Constants.keyBoardHeight,
      margin: EdgeInsets.only(top: 5),
      child: GridView.count(
        //水平子Widget之间间距
        crossAxisSpacing: 5,
        //垂直子Widget之间间距
        mainAxisSpacing: 5,
        //一行的Widget数量
        crossAxisCount: 7,
        //子Widget宽高比例
        childAspectRatio: 1,
        //子Widget列表
        children: getEmojiList(callBack),
      ),
    );
}

final int emojiNum = 19; //个数

  ///emoji数据
  List<String> getDataList() {
    List<String> list = [];
    for (int i = 1; i <= emojiNum; i++) {
      if (i < 10) {
        list.add("images/emoji/e1000$i.png");
      } else if (i >= 10 && i < 100) {
        list.add("images/emoji/e100$i.png");
      } else {
        list.add("images/emoji/e10$i.png");
      }
    }
    return list;
  }

///返回emoji组件集合
  List<Widget> getEmojiList(callBack) {
    return getDataList().map((item) => getItemContainer(item, callBack)).toList();
  }

Widget getItemContainer(String item, callBack) {
    return InkWell(
      onTap: () {
        print('kkkkkkkkkkkkkkkkkkkkkkkkkkkk$item');
        String emojiName =
            item.substring(item.lastIndexOf("/") + 1, item.indexOf("."));
        callBack("<em>$emojiName</em>");
      },
      child: Container(
        alignment: Alignment.center,
        child: Image.asset(
          '$item',
          width: 30,
          height: 30,
        ),
      ),
    );
  }