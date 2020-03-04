import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/components/loading_state.dart';
import 'package:premades_nn/model/system_notice_entity.dart';
import 'package:premades_nn/page/news/system_notice_detail_screen.dart';
import 'package:premades_nn/service/service.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/utils/ColorUtil.dart';
import 'package:premades_nn/utils/Constants.dart';
import 'package:premades_nn/utils/Strings.dart';

class SystemNoticeScreen extends StatefulWidget {
  @override
  _SystemNoticeScreenState createState() => _SystemNoticeScreenState();
}

class _SystemNoticeScreenState extends LoadingState<SystemNoticeScreen> {
  List<SystemNoticeEntity> _datas = List();

  @override
  void initLoadingState() {
    title = Strings.systemNotice;
    Constants.systemNoticeCount = 0;
    initData();
  }

  @override
  Widget loadingFailureWidget() {
    return null;
  }

  @override
  Widget loadingSuccessWidget() {
    return Material(
      color: ColorUtil.greyBG,
      child: Column(
        children: <Widget>[
          AppBarWidget(
            isShowBack: true,
            centerText: title,
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                itemCount: _datas.length,
                itemBuilder: (context, index) {
                  return listItem(_datas[index]);
                }),
          ),
        ],
      ),
    );
    ;
  }

  @override
  Widget loadingWidget() {
    return null;
  }

  ///获取系统公告列表
  void initData() {
    Map formData = {"page": 1, "limit": 50};
    request("post", allUrl["systemNotice"], formData).then((result) {
      if (result["code"] == 0 &&
          result["data"] != null &&
          result["data"]["list"] != null) {
        (result["data"]["list"] as List).forEach((item) {
          _datas.add(SystemNoticeEntity.fromJson(item));
        });
        if (_datas.length > 0) {
          loadingSuccess();
        } else {
          loadingFailure(Strings.emptyData);
        }
      } else {
        loadingFailure(Strings.emptyData);
      }
    });
  }

  ///系统公告item
  Widget listItem(SystemNoticeEntity data) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(5)),//底色圆角
        child: Ink(
          child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(5)),//水波纹圆角
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return SystemNoticeDetailScreen(systemNoticeId: data.id,);
              }));
            },
            child: Column(
              children: <Widget>[
                Offstage(
                  offstage: data.cover == null || data.cover == "",
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                    child: FadeInImage.assetNetwork(
                      placeholder: "images/image_default.png",
                      image: data.cover,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
                          height: ScreenUtil().setHeight(45),
                          child: Text(
                            data.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: ColorUtil.black,
                                fontSize: ScreenUtil().setSp(15),
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: ScreenUtil().setWidth(10), left: ScreenUtil().setWidth(10)),
                        height: ScreenUtil().setHeight(45),
                        child: Text(
                          Constants.showContentBySeconds(data.releaseTime),
                          style: TextStyle(
                              color: ColorUtil.grey,
                              fontSize: ScreenUtil().setSp(12),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),


    );
  }
}
