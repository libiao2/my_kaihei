import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:convert/convert.dart';
import 'package:premades_nn/components/NetLoadingDialog.dart';
import 'package:premades_nn/event/verification_code_event.dart';
import 'package:premades_nn/model/user_info_entity.dart';
import 'package:premades_nn/type/VerificationCodeType.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:photo_manager/photo_manager.dart';

import 'ImageUtil.dart';

class Constants {
  static File headImgFile = null;

  static bool isSendError;

  // 保存上下文
  static var cardListContext;

  static var roomContext = null;

  //用户个人信息
  static UserInfoEntity userInfo = new UserInfoEntity();

  //部分接口 用户验证token
  static String token;

  //IM 语音 WebSocket
  static WebSocketChannel channel;

  static String gateway;

  static bool isCancle;

  //是否再聊天页面
  static bool isOnChatScreen = false;

  //当前聊天用户nnid
  static int curChatUserId;

  //是否再群聊天页面
  static bool isOnGroupChatScreen = false;

  //是否在通话页面
  static bool isOnCalling = false;

  //是否在聊天页面
  static bool isOnMessageScreen = false;

  //当前群聊id
  static int curChatGroupNo;

  static List chatList = [];

  static var room_context;

  static var APP_ID = '6a7cffe477a748098e35c97ca9c32bae';

  //键盘高度
  static double keyBoardHeight;

  //屏幕高度
  static double screenHeight;

  //状态栏高度
  static double statusBarHeight;

  static bool connected = true; //网络连接是否可用  wifi没网可会算是有网

  static bool isFirst = false; //是否第一次登录

  List get getChatList => chatList; // 获取聊天列表方法

  //事件控制
  static EventBus eventBus = new EventBus();

  static List<AssetEntity> selectedList = List();
  static const int MAX_COUNT = 20;

  //声网插件
//  static const agoraPlatform = const MethodChannel("agora.voice");

  //极验证插件
  static MethodChannel geetestPlatform = const MethodChannel("geetest.gt3");

  //当前验证码类型
  static VerificationCodeType curType;

  //主context
  static BuildContext mainContext;

  static int systemMessageCount = 0; //消息助手未读消息数
  static String systemMessageLastContent; //消息助手最后一条消息
  static int systemNoticeCount = 0; //系统消息未读消息数
  static String systemNoticeLastContent; //系统消息最后一条消息

  //app 状态
  static AppLifecycleState appState;

  static String smscodeKey;

  ///创建项目根目录
  static Future<String> createRootDir() async {
    Directory appDocDir = await getExternalStorageDirectory();
    Directory directory = Directory(appDocDir.path + "/雷神NN");
    if (!await directory.exists()) {
      directory.create();
    }
    return directory.path;
  }

  ///创建录音文件目录
  static Future<String> createRecordPath() async {
    String rootPath = await createRootDir();

    ///创建用户目录
    Directory userDir =
    Directory(rootPath + "/" + Constants.userInfo.nnId.toString());
    if (!await userDir.exists()) {
      userDir.create();
    }

    ///创建录音文件根目录
    Directory recordDir = Directory(userDir.path + "/record");
    if (!await recordDir.exists()) {
      recordDir.create();
    }

    return recordDir.path;
  }

  static Future<String> loadCache() async {
    String result;
    try {
      Directory tempDir = await getTemporaryDirectory();
      double value = await _getTotalSizeOfFilesInDir(tempDir);
      /*tempDir.list(followLinks: false,recursive: true).listen((file){
          //打印每个缓存文件的路径
        print(file.path);
      });*/
      print('临时目录大小: ' + value.toString());
      result = value.toString();
    } catch (err) {
      print(err);
    }
    return result;
  }

  /// 递归方式 计算文件的大小
  static Future<double> _getTotalSizeOfFilesInDir(
      final FileSystemEntity file) async {
    try {
      if (file is File) {
        int length = await file.length();
        return double.parse(length.toString());
      }
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        double total = 0;
        if (children != null)
          for (final FileSystemEntity child in children)
            total += await _getTotalSizeOfFilesInDir(child);
        return total;
      }
      return 0;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  static Future<int> clearCache(BuildContext context) async {
    //此处展示加载loading
    NetLoadingDialog.showLoadingDialog(context, "清除缓存中...");
    try {
      Directory tempDir = await getTemporaryDirectory();
      //删除缓存目录
      await delDir(tempDir);
      //删除头像存储文件
      await ImageUtil.clearCache();
      return 1;
    } catch (e) {
      print(e);
      return 0;
    } finally {
      //此处隐藏加载loading
      Navigator.pop(context);
    }
  }

  ///递归方式删除目录
  static Future<Null> delDir(FileSystemEntity file) async {
    try {
      if (file is Directory) {
        final List<FileSystemEntity> children = file.listSync();
        for (final FileSystemEntity child in children) {
          await delDir(child);
        }
      }
      await file.delete();
    } catch (e) {
      print(e);
    }
  }

  ///md5加密
  static String generateMd5(String data) {
    var content = Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }

  /// 验证手机号
  static bool phoneIsOk(String str) {
    return new RegExp(
        '^((13[0-9])|(15[^4])|(166)|(17[0-8])|(18[0-9])|(19[8-9])|(147,145))\\d{8}\$')
        .hasMatch(str);
  }

  /// 检查是否是邮箱格式
  static bool isEmail(String input) {
    if (input == null || input.isEmpty) return false;
    return new RegExp("^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*\$")
        .hasMatch(input);
  }

  /// 验证NN号
  static bool isNNID(String str) {
    return str.length >= 5 && str.length <= 9;
  }

  /// 判断图片
  static String isImage(String str) {
    if (str.length > 5) {
      return str.substring(0, 5) == 'https'
          ? str
          : 'http://static.nn.com' + str;
    }
    return 'http://static.nn.com' + str;
  }

  ///根据时间戳获取字符串
  static String timestamp2String(int timestamp) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    return date.toString().substring(0, date.toString().lastIndexOf("."));
  }

  ///根据时间戳来获取提示内容   毫秒
  ///1天内---只显示 时:分
  ///一年内---只显示 月-日 时:分
  ///一年之外---显示 年-月-日 时:分
  ///2019-10-12 15:08:12.3536
  static String showContentByTime(int timestampMilliseconds) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(
        timestampMilliseconds);
    return _getContentByTime(date);
  }

  ///根据时间戳来获取提示内容   秒
  ///1天内---只显示 时:分
  ///一年内---只显示 月-日 时:分
  ///一年之外---显示 年-月-日 时:分
  ///2019-10-12 15:08:12.3536
  static String showContentBySeconds(int seconds) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    return _getContentByTime(date);
  }

  static String _getContentByTime(DateTime date) {
    String showContent = "";
    DateTime now = DateTime.now();
    String time = date.toString();
    if (now.year > date.year) {
      showContent = time.substring(0, time.lastIndexOf(":"));
    } else if (now.year == date.year && now.month > date.month) {
      showContent =
          time.substring(time.indexOf("-") + 1, time.lastIndexOf(" "));
    } else if (now.year == date.year &&
        now.month == date.month &&
        now.day > date.day) {
      showContent =
          time.substring(time.indexOf("-") + 1, time.lastIndexOf(" "));
    } else if (now.year == date.year &&
        now.month == date.month &&
        now.day == date.day) {
      showContent =
          time.substring(time.indexOf(" ") + 1, time.lastIndexOf(":"));
    } else {
      showContent = time.substring(0, time.lastIndexOf(":"));
    }
    return showContent;
  }

  ///根据生日获取星座
  ///2014-11-17
  static String getConstellation(String birthday) {
    final String capricorn = '摩羯座'; //Capricorn 摩羯座（12月22日～1月20日）
    final String aquarius = '水瓶座'; //Aquarius 水瓶座（1月21日～2月19日）
    final String pisces = '双鱼座'; //Pisces 双鱼座（2月20日～3月20日）
    final String aries = '白羊座'; //3月21日～4月20日
    final String taurus = '金牛座'; //4月21～5月21日
    final String gemini = '双子座'; //5月22日～6月21日
    final String cancer = '巨蟹座'; //Cancer 巨蟹座（6月22日～7月22日）
    final String leo = '狮子座'; //Leo 狮子座（7月23日～8月23日）
    final String virgo = '处女座'; //Virgo 处女座（8月24日～9月23日）
    final String libra = '天秤座'; //Libra 天秤座（9月24日～10月23日）
    final String scorpio = '天蝎座'; //Scorpio 天蝎座（10月24日～11月22日）
    final String sagittarius = '射手座'; //Sagittarius 射手座（11月23日～12月21日）

    List<String> split = birthday.split("-");
    int month = int.parse(split[1]);
    int day = int.parse(split[2]);
    String constellation = '';

    switch (month) {
      case DateTime.january:
        constellation = day < 21 ? capricorn : aquarius;
        break;
      case DateTime.february:
        constellation = day < 20 ? aquarius : pisces;
        break;
      case DateTime.march:
        constellation = day < 21 ? pisces : aries;
        break;
      case DateTime.april:
        constellation = day < 21 ? aries : taurus;
        break;
      case DateTime.may:
        constellation = day < 22 ? taurus : gemini;
        break;
      case DateTime.june:
        constellation = day < 22 ? gemini : cancer;
        break;
      case DateTime.july:
        constellation = day < 23 ? cancer : leo;
        break;
      case DateTime.august:
        constellation = day < 24 ? leo : virgo;
        break;
      case DateTime.september:
        constellation = day < 24 ? virgo : libra;
        break;
      case DateTime.october:
        constellation = day < 24 ? libra : scorpio;
        break;
      case DateTime.november:
        constellation = day < 23 ? scorpio : sagittarius;
        break;
      case DateTime.december:
        constellation = day < 22 ? sagittarius : capricorn;
        break;
    }

    return constellation;
  }

  static int time = 0;
  static Timer timer;

  ///开始计时器
  static void startCountdownTimer(Function callback) {
    print("开始计时");
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      time++;
      print("计时 $time");
      if (time >= 10){
        if (callback != null){
          callback();
        }
        timer.cancel();
        time = 0;
      }
    });
  }
}
