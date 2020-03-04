import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:premades_nn/service/service_url.dart';
import 'package:premades_nn/type/FileType.dart';
import 'Constants.dart';

class ImageUtil {
  static Future fetchImage(String url, String imageName) async {
    String rootDir = await Constants.createRootDir();

    final imageFile =
    File(path.join(rootDir, imageName + '.png')); // 保存在应用文件夹内

    Constants.headImgFile = imageFile;
    if (!await imageFile.exists()) {
      final res = await Dio().download(url, imageFile.path);
//      final image = img.decodeImage(res.data.bodyBytes);
//      await imageFile
//          .writeAsBytes(img.encodePng(image)); // 需要使用与图片格式对应的encode方法
    }
  }

  // 上传文件
  static Future uploadImg(imgfile, {int fileType}) async{
    String path = imgfile.path;
    String name = path.substring(path.lastIndexOf("/") + 1, path.length);
    String suffix = path.substring(path.lastIndexOf(".") + 1, path.length);
    FormData formData = new FormData.from({
      "file": new UploadFileInfo(new File(path), name,
          contentType: ContentType.parse("image/$suffix"))
    });
    Response response;
    Dio dio =new Dio();
    if (fileType == null || fileType == FileType.IMAGE){
      response = await dio.post(uploadImageUrl,data: formData);
    } else if (fileType == FileType.AUDIO){
      response = await dio.post(uploadAudioUrl,data: formData);
    }

    if(response.statusCode == 200){
      return response.data;
    }else{
      throw Exception('后端接口异常');
    }
  }

  static Future<void> clearCache() async {
    Directory appDocDir = await getExternalStorageDirectory();
    Directory directory = Directory(appDocDir.path + "/雷神NN");
    if (!await directory.exists()) {
      directory.create();
    }
    try {
      directory.list(followLinks: false, recursive: true).listen((file) {
        file.delete();
      });
    } catch (e) {
      print(e);
    }
  }
}
