import 'package:flutter/material.dart';
import 'package:flutter_drag_scale/flutter_drag_scale.dart';

class ImageView extends StatefulWidget {
  ///搜索好友页面和频道用户页面查看用户详情接口不一样
  ///一个是通过nnid查询，一个是通过频道用户编号查询
  final String img;

  ImageView({Key key, this.img}) : super(key: key);

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {

  bool isShowAddFriendBtn = true;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(
                right: 20,
                top: 20,
              ),
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: (){
                  onCloseClick();
                },
                child: Icon(Icons.cancel, size: 30, color: Colors.white,)
              ),
            ),
            Expanded(
              child: DragScaleContainer(
                doubleTapStillScale: true,
                child: Image(
                  image: NetworkImage(
                      widget.img
                  ),
                ),
              )
            )
          ],
        )
    );
  }


  void onCloseClick() {
    Navigator.of(context).pop();
  }
}
