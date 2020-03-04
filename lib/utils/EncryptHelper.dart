import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;
 
final parser = RSAKeyParser();
 
class EncryptHelper {
 
  static Future<String> decode(String decoded) async {
    String privateKeyString = await rootBundle.loadString('keys/private_key.pem');
 
    final privateKey = parser.parse(privateKeyString);
 
    final encrypter = Encrypter(RSA(privateKey: privateKey));
    return encrypter.decrypt(Encrypted.fromBase64(decoded));
  }
 
  // 长参数分段加密
  static Future<String> encodeLong(Map para) async{
    // 设置加密对象
    String publicKeyString = await rootBundle.loadString('keys/public_key.pem');
    RSAPublicKey publicKey = parser.parse(publicKeyString);
    final encrypter = Encrypter(RSA(publicKey: publicKey));
    // map转成json字符串
    final jsonStr = jsonEncode(para);
    // 原始json转成字节数组
    List<int> sourceByts = utf8.encode(jsonStr);
    // 数据长度
    int inputLen = sourceByts.length;
    // 加密最大长度
    int maxLen = 117;
    // 存放加密后的字节数组
    List<int> totalByts = List();
    // 分段加密 步长为117
    for (var i = 0; i < inputLen; i += maxLen) {
      // 还剩多少字节长度
      int endLen = inputLen - i;
      List<int> item;
      if (endLen > maxLen) {
        item = sourceByts.sublist(i, i+maxLen);
      }else{
        item = sourceByts.sublist(i, i+endLen);
      }
      // 加密后的对象转换成字节数组再存放到容器
      totalByts.addAll(encrypter.encryptBytes(item).bytes);
    }
    // 加密后的字节数组转换成base64编码并返回
    String en = base64.encode(totalByts);
    return en;
  }
 
}