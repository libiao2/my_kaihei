import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';

///emoji/image text
class EmojiText extends SpecialText {
  static const String flag = "<em>";
  final int start;
  EmojiText(TextStyle textStyle, {this.start})
      : super(EmojiText.flag, "</em>", textStyle);

  @override
  InlineSpan finishText() {
    var key = toString1();
    if (EmojiUitl.instance.emojiMap.containsKey(key)) {
      //fontsize id define image height
      //size = 30.0/26.0 * fontSize
      final double size = 20.0;

      ///fontSize 26 and text height =30.0
      //final double fontSize = 26.0;

      return ImageSpan(AssetImage(EmojiUitl.instance.emojiMap[key]),
          actualText: key,
          imageWidth: size,
          imageHeight: size,
          start: start,
          fit: BoxFit.fill,
          margin: EdgeInsets.only(left: 2.0, right: 2.0));
    }

    return TextSpan(text: toString(), style: textStyle);
  }
}

class EmojiUitl {
  final Map<String, String> _emojiMap = new Map<String, String>();

  Map<String, String> get emojiMap => _emojiMap;

  static EmojiUitl _instance;
  static EmojiUitl get instance {
    if (_instance == null) _instance = new EmojiUitl._();
    return _instance;
  }

  EmojiUitl._() {
    for (int i = 1; i < 19; i++) {
      if (i < 10){
        _emojiMap["<em>e1000$i</em>"] = "images/emoji/e1000$i.png";
      } else if (i >= 10 && i <100){
        _emojiMap["<em>e100$i</em>"] = "images/emoji/e100$i.png";
      } else {
        _emojiMap["<em>e10$i</em>"] = "images/emoji/e10$i.png";
      }

    }
  }
}
