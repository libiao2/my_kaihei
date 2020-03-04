import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:premades_nn/components/AppBarWidget.dart';
import 'package:premades_nn/utils/Strings.dart';

class PrivacyProtocol extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          AppBarWidget(
            isShowBack: true,
            centerText: Strings.privacyProtocol,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(ScreenUtil().setWidth(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                        '       NN全球游戏社交平台（以下称“NN”）隐私权保护声明是NN保护用户个人隐私的承诺。鉴于网络的特性，NN不可避免地将与您产生直接或间接的互动，故特此说明NN针对用户个人信息所采用的收集、使用和保护政策，请您务必仔细阅读：'),
                    Text(''),
                    Text('1.使用者非个人化信息'),
                    Text(''),
                    Text(
                        '       我们将通过您的 IP 地址来收集非个人化的信息，例如您的浏览器性质、操作系统种类、服务的 ISP 的域名等，以优化NN在您计算机屏幕上显示的页面。我们也会通过收集上述信息，进行客流量统计，从而改进网站的管理和服务。'),
                    Text(''),
                    Text('2.个人资料'),
                    Text(''),
                    Text(
                        '2.1 当您在NN进行用户注册登记、或参与公共论坛等活动时，在您的同意及确认下，NN将通过注册表格、订单等形式要求您提供一些个人资料。这些个人资料包括：'),
                    Text(''),
                    Text(
                        '2.1.1 个人识别资料：如姓名、性别、年龄、出生日期、身份证号码（或护照号码）、电话、通信地址、住址、电子邮件地址等信息。'),
                    Text(''),
                    Text('2.2 在未经您同意及确认之前，NN不会将您为参加本网站特定活动，所提供的资料利用于其它目的。'),
                    Text(''),
                    Text('3.信息安全'),
                    Text(''),
                    Text(
                        '3.1 NN将对您所提供的资料进行严格的管理及保护，NN将使用相应的技术，防止您的个人资料丢失、被盗用或遭篡改。'),
                    Text(''),
                    Text(
                        '3.2 NN在必要时会委托专业技术人员代为对该类资料进行电脑处理，以符合专业分工时代的需求。 如NN将电脑处理的通知送达给您，而您未在通知中规定的时间内主动明示反对，NN将默认您已同意。'),
                    Text(''),
                    Text('4.用户权利'),
                    Text(''),
                    Text('4.1 您对于自己的个人资料享有以下权利：'),
                    Text(''),
                    Text('4.1.1 随时查询及请求阅览；'),
                    Text(''),
                    Text('4.1.2 可以联系客服提供相关信息进行修改；'),
                    Text(''),
                    Text('4.1.3 请求停止电脑处理及利用。'),
                    Text(''),
                    Text('4.2 针对以上权利，本网站为您提供相关服务，同时如果您有疑问，请联系在线客服。'),
                    Text(''),
                    Text('5.限制利用原则'),
                    Text(''),
                    Text('       NN在符合下列任一条件的情况下，将会对收集的用户个人资料进行必要范围以外的利用：'),
                    Text(''),
                    Text('5.1 已取得您的书面同意；'),
                    Text(''),
                    Text('5.2 为免除您在生命、身体或财产方面的急迫危险；'),
                    Text(''),
                    Text('5.3 为防止他人权益受到重大危害；'),
                    Text(''),
                    Text('5.4 为增进公共利益，且无损害您的重大利益。'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
