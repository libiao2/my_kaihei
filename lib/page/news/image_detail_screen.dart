import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/utils/Strings.dart';

class ImageDetailScreen extends StatelessWidget {
  int imageWidth;

  int imageHeight;

  String url;

  ImageDetailScreen({Key key, this.url, this.imageWidth, this.imageHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //计算图片显示尺寸
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight =
        MediaQuery.of(context).size.height - Constants.statusBarHeight - 50;

    double height;
    if (imageHeight == null || imageHeight == 0) {
      height = screenWidth;
    } else {
      height = screenWidth / imageWidth * imageHeight;
    }

    print("width ; $screenWidth, height : $height");
    print("imageWidth ; $imageWidth, imageHeight : $imageHeight");

    return Material(
      child: Column(
        children: <Widget>[
          AppBarWidget(isShowBack: true),
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                color: Colors.white,
                height: height < screenHeight ? screenHeight : height,
                child: Center(
                  child: Image.network(
                    url,
                    width: screenWidth,
                    height: height,
                    fit: BoxFit.fill,
                  ),
//              FadeInImage.memoryNetwork(
//                placeholder: kTransparentImage,
//                image: url,
//                width: screenWidth,
//                height: height,
//                fit: BoxFit.fill,
//              ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
}
