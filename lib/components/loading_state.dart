import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/utils/ColorUtil.dart';

enum StateType {
  isLoading,
  loadFailure,
  loadSuccess,
}

abstract class LoadingState<T extends StatefulWidget> extends State<T> {
  StateType stateType = StateType.isLoading;

  Widget _loadingWidget;

  Widget _loadingFailureWidget;

  String title = "标题";

  String _errorTip;

  @override
  void initState() {
    super.initState();
    _loadingWidget = loadingWidget();
    _loadingFailureWidget = loadingFailureWidget();

    initLoadingState();
  }

  @override
  Widget build(BuildContext context) {
    if (stateType == StateType.isLoading) {
      if (_loadingWidget == null) {
        _loadingWidget = Container(
          color: ColorUtil.greyBG,
          child: Column(
            children: <Widget>[
              AppBarWidget(
                isShowBack: true,
                centerText: title,
              ),
              Expanded(
                child: Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Colors.orange,
                )),
              ),
            ],
          ),
        );
      }

      return _loadingWidget;
    } else if (stateType == StateType.loadFailure) {
      if (_loadingFailureWidget == null) {
        _loadingFailureWidget = Container(
            color: ColorUtil.greyBG,
            child: Column(
              children: <Widget>[
                AppBarWidget(
                  isShowBack: true,
                  centerText: title,
                ),
                _emptyDataWidget(),
              ],
            )
        );
      }
      return _loadingFailureWidget;
    } else if (stateType == StateType.loadSuccess) {
      return loadingSuccessWidget();
    }
    return null;
  }

  Widget _emptyDataWidget() {
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 100,
            height: 100,
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(50)),
            decoration: new BoxDecoration(
              image:
                  new DecorationImage(image: AssetImage("images/no_list.png")),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
          child: Text(
            _errorTip,
            style: TextStyle(fontSize: ScreenUtil().setSp(16), color: Colors.grey, decoration: TextDecoration.none),
          ),
        ),
      ],
    );
  }

  void loadingFailure(String errorTip) {
    setState(() {
      _errorTip = errorTip;
      stateType = StateType.loadFailure;
    });
  }

  void loadingSuccess() {
    setState(() {
      stateType = StateType.loadSuccess;
    });
  }

  @protected
  Widget loadingWidget();

  @protected
  Widget loadingFailureWidget();

  @protected
  Widget loadingSuccessWidget();

  @protected
  void initLoadingState();
}
