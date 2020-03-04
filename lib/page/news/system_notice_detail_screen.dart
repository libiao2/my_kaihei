import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/loading_state.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Strings.dart';

class SystemNoticeDetailScreen extends StatefulWidget{

  final int systemNoticeId;

  SystemNoticeDetailScreen({this.systemNoticeId});

  @override
  _SystemNoticeDetailScreenState createState() => _SystemNoticeDetailScreenState();

}

class _SystemNoticeDetailScreenState extends LoadingState<SystemNoticeDetailScreen>{

  String content;
  @override
  void initLoadingState() {
    initData();
  }

  @override
  Widget loadingFailureWidget() {
    return null;
  }

  @override
  Widget loadingSuccessWidget() {
    return Container(
        color: ColorUtil.greyBG,
        child: Column(
          children: <Widget>[
            AppBarWidget(
              isShowBack: true,
              centerText: Strings.systemNotice,
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ScreenUtil().setWidth(10)),
              child: Html(
                defaultTextStyle: TextStyle(color: ColorUtil.htmlGrey, fontSize: ScreenUtil().setSp(14), decoration: TextDecoration.none, fontWeight: FontWeight.normal),
                data: content
              ),
            ),

          )

          ],
        )
    );;
  }

  @override
  Widget loadingWidget() {
    return null;
  }

  void initData(){
    Map formData = {
      "id": widget.systemNoticeId
    };
    request("post", allUrl["systemNoticeDetail"], formData).then((result){
      if (result != null && result["code"] == 0){
        setState(() {
          content = result["data"]["content"];
        });
        if (content == null || content == ""){
          loadingFailure(Strings.emptyData);
        } else {
          loadingSuccess();
        }
      } else {
        loadingFailure(Strings.emptyData);
      }
    });
  }
}