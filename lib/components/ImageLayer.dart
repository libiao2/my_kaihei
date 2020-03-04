import 'package:flutter/material.dart';

import 'package:photo_manager/photo_manager.dart';
import 'package:premades_nn/utils/Constants.dart';

class ImageLayer extends StatefulWidget{

  final AssetEntity assetEntity;

  ImageLayer({this.assetEntity});

  @override
  ImageLayerState createState() => ImageLayerState();
}

class ImageLayerState extends State<ImageLayer>{
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Constants.keyBoardHeight - 50,
      child: Stack(
        children: <Widget>[
          _buildMask(containsEntity(widget.assetEntity)),
          _buildSelected(widget.assetEntity),
        ],
      ),
    );

  }

  _buildMask(bool showMask) {
    return IgnorePointer(
      child: AnimatedContainer(
        color: showMask ? Colors.black.withOpacity(0.5) : Colors.transparent,
        duration: Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildSelected(AssetEntity entity) {
    var currentSelected = containsEntity(entity);
    return Positioned(
      right: 0.0,
      width: 36.0,
      height: 36.0,
      child: GestureDetector(
        onTap: () {
          changeCheck(!currentSelected, entity);
        },
//        behavior: HitTestBehavior.translucent,
        child: _buildText(entity),
      ),
    );
  }

  Widget _buildText(AssetEntity entity) {
    var isSelected = containsEntity(entity);
    Widget child;
    BoxDecoration decoration;
    if (isSelected) {
      child = Text(
        (indexOfSelected(entity) + 1).toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.white,
        ),
      );
      decoration = BoxDecoration(color: Colors.grey);
    } else {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(1.0),
        border: Border.all(
          color: Colors.grey,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: decoration,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  void changeCheck(bool value, AssetEntity entity) {
    if (value) {
      addSelectEntity(entity);
    } else {
      removeSelectEntity(entity);
    }
    setState(() {});
  }

  bool containsEntity(AssetEntity entity) {
    return Constants.selectedList.contains(entity);
  }

  int indexOfSelected(AssetEntity entity) {
    return Constants.selectedList.indexOf(entity);
  }

  bool isUpperLimit(){
    return Constants.selectedList.length > Constants.MAX_COUNT;
  }

  bool addSelectEntity(AssetEntity entity) {
    if (containsEntity(entity)) {
      return false;
    }
    if (isUpperLimit() == true) {
      return false;
    }
    Constants.selectedList.add(entity);
    return true;
  }

  bool removeSelectEntity(AssetEntity entity) {
    return Constants.selectedList.remove(entity);
  }
}