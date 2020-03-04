import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchBox extends StatefulWidget {
  final Function onChanged;
  final bool cancelable;
  final Function onSearchBtnClick;
  final List<TextInputFormatter> formatter;
  final TextInputType inputType;
  final String hintText;
  const SearchBox({Key key, this.onChanged, this.cancelable = false, this.onSearchBtnClick, this.formatter, this.inputType,this.hintText}) : super(key: key);
  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  TextEditingController _inputController = TextEditingController();
  String searchValue;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: inputBox(),
          ),
          widget.cancelable?tapWrap(
            Text('取消',style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(15)),),
            _back
          ):tapWrap(
            Text('搜索',style: TextStyle(fontSize: ScreenUtil.getInstance().setSp(15)),),
            _searchBtnClick
          )
        ],
      ),
      padding: EdgeInsets.all(10),
    );
  }
  // 输入框
  Widget inputBox(){
    return Container(
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search,
            color: Color.fromRGBO(175, 175, 175, 1),
          ),
          Expanded(
            flex: 1,
            child: TextField(
              keyboardType: widget.inputType,
              inputFormatters: widget.formatter,
              controller: _inputController,
              autofocus: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                hintText: widget.hintText,
                hintStyle: TextStyle(color: Color.fromRGBO(207, 207, 207, 1),fontSize: ScreenUtil.getInstance().setSp(14)),
                border: OutlineInputBorder(
                  // borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide.none
                )
              ),
              onChanged: _onChanged,
            ),
          )
        ],
      ),
      padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Color.fromRGBO(242, 242, 242, 1),
        borderRadius: BorderRadius.all(Radius.circular(20))
      ),
    );
  }
  // 可点击区域
  Widget tapWrap(Widget child, Function callback){
    return GestureDetector(
      onTap: (){
        if(callback != null) callback();
      },
      child: child,
    );
  }
  // 输入框改变事件
  _onChanged(val){
    setState(() {
     searchValue = val; 
    });
    if(widget.onChanged != null) widget.onChanged(val);
  }
  // 点击搜索按钮
  _searchBtnClick(){
    if(widget.onSearchBtnClick != null && searchValue != '') widget.onSearchBtnClick(searchValue);
  }
  _back(){
    Navigator.pop(context);
  }
}