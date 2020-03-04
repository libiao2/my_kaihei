class VerificationCodeEvent{

  //true:极验证成功   false:极验证失败
  bool validateStatus;


  VerificationCodeEvent(this.validateStatus);
}

//  SmsTypeLogin           = 1 // 登录
//  SmsTypeRegister        = 2 // 注册
//  SmsTypeBind            = 3 // 绑定
//  SmsTypeReset           = 4 // 找回密码
//  SmsTypeUnbind          = 5 // 解绑
//  SmsTypeChangeBind      = 6 // 更换绑定
//  SmsTypeDismissChannel  = 7 // 解散频道
//  SmsTypeTransferChannel = 8 // 转让频道
class ValidateType{
  static const int login = 1;
  static const int register = 2;
  static const int forgetPassword = 4;
}