import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:open_file/open_file.dart';
import 'package:ota_update/ota_update.dart';
import 'package:path_provider/path_provider.dart';
import 'package:install_plugin/install_plugin.dart';

///自定义dialog
///执行下载操作
///显示下载进度
///下载完成后执行安装操作
///[version]新版本的版本号,[url]新版本app下载地址
class DownloadProgressDialog extends StatefulWidget {
  DownloadProgressDialog(this.version,this.url,{Key key}) : super(key: key);

  final String version;
  final String url;

  @override
  _DownloadProgressDialogState createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {

  //下载进度
  int progress;

  String downloadId;

  String _localPath;

  String taskId;
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    //初始化下载进度
    progress = 0;
    // //开始下载
    
    var download = executeDownload(widget.url);
    download.then((value){
      taskId = value;
    });
  }


  @override
void dispose() {
	IsolateNameServer.removePortNameMapping('downloader_send_port');
	super.dispose();
}

  @override
  Widget build(BuildContext context) {
    //显示下载进度
    return AlertDialog(
      title: Text('更新中'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text(widget.version),
            Text(''),
            Text('下载进度 $progress%'),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('后台更新'),
          onPressed: () {
            //取消当前下载
            if(this.taskId != null){
              BackUpdate().cancelDownload(this.taskId);
            }
            //执行后台下载
            // BackUpdate().executeDownload(widget.url);
            //关闭下载进度窗口
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    print('=====================6667777======================');
    //更新下载进度
    progress = progress;
    // setState(() => this.progress = progress);
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port');
	  send.send([id, status, progress]);
    print('SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS${progress}');
    // 当下载完成时，调用安装
    // if (taskId == id && status == DownloadTaskStatus.complete){
    //   //关闭更新进度框
    //   Navigator.of(context).pop();
    //   //安装下载完的apk
    //   BackUpdate()._installApk();
    // }
  }

  /// 下载
  Future<String> executeDownload(String apkUrl) async {
    // WidgetsFlutterBinding.ensureInitialized();
    // await FlutterDownloader.initialize();

    // IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    //   _port.listen((dynamic data) {
    //     String id = data[0];
    //     DownloadTaskStatus status = data[1];
    //     int progress = data[2];
    //     setState((){ });
    //   });


    // final path = await BackUpdate()._apkLocalPath();
    // //发起请求
    // taskId = await FlutterDownloader.enqueue(
    //   url: apkUrl,
    //   fileName: 'leigod_nn.apk',
    //   savedDir: path,
    //   showNotification: false,
    //   openFileFromNotification: false);

    //   print('MMMMMMMMMMMMMMMDDDDDDDDDDDDDDDD');
    //   FlutterDownloader.registerCallback(downloadCallback);
    //   return taskId;

    // 获取APP安装路径
     Directory appDocDir = await getApplicationDocumentsDirectory();
     String appDocPath = appDocDir.path;
     
    if (Platform.isIOS){
      // String url = 'itms-apps://itunes.apple.com/cn/app/id414478124?mt=8'; //到时候换成自己的应用的地址
      // 通过url_launcher插件来跳转AppStore
      // if (await canLaunch(url)){
      //   await launch(url);
      // }else {
      //   throw 'Could not launch $url';
      // }
    }else if (Platform.isAndroid){
      String url = apkUrl;
      print(url);
      try {
        OtaUpdate().execute(url).listen(
              (OtaEvent event) {
            print('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa:${event.status},value:${event.value}');
            switch(event.status){
              case OtaStatus.DOWNLOADING: // 下载中
                setState(() {
                  if(int.parse(event.value) < 0) {
                    this.progress = 100 + int.parse(event.value);
                  } else {
                    this.progress = int.parse(event.value);
                  }
                });
                break;
              case OtaStatus.INSTALLING: //安装中
                  print('-----安装中----');
                  Navigator.of(context).pop();
                  // 打开安装文件
                  //这里的这个Apk文件名可以写，也可以不写
                  //不写的话会出现让你选择用浏览器打开，点击取消就好了，写了后会直接打开当前目录下的Apk文件，名字随便定就可以
                  OpenFile.open("${appDocPath}/new.apk");
                break;
              case OtaStatus.PERMISSION_NOT_GRANTED_ERROR: // 权限错误
                print('更新失败，请稍后再试');
                
                break;
              default: // 其他问题
                break;
            }
          },
        );
      } catch (e) {
        print('更新失败，请稍后再试');
      }
    }
  }

}

///后台下载
class BackUpdate{

  Future<void> executeDownload(String url) async {
    final path = await _apkLocalPath();
    //发起请求
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      fileName: 'leigod_nn.apk',
      savedDir: path,
      showNotification: true,
      openFileFromNotification: false);
    FlutterDownloader.registerCallback((id, status, progress) {	
      // 当下载完成时，调用安装	 
      if (taskId == id && status == DownloadTaskStatus.complete) {	 
        //安装下载完的apk	 
        _installApk();	 
      }
      });
  }

  ///取消下载
  cancelDownload(String taskId) async{
    FlutterDownloader.cancel(taskId: taskId);
  }

  /// 安装
  Future<Null> _installApk() async {
    try {
      final path = await _apkLocalPath();

      InstallPlugin.installApk(path + '/update.apk', 'com.example.app_update_demo')
          .then((result) {
        print('install apk $result');
      }).catchError((error) {
        print('install apk error: $error');
      });
    } on PlatformException catch (_) {}
  }

  /// 获取存储路径
  Future<String> _apkLocalPath() async {
    //获取根目录地址
    final dir = await getExternalStorageDirectory();
    //自定义目录路径(可多级)
    String path = dir.path+'/appUpdateDemo';
    var directory = await new Directory(path).create(recursive: true);
    return directory.path;
  }
}