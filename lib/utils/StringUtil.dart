import 'package:premades_nn/utils/Strings.dart';

class StringUtil{

  static String passWordVerification(String password){
    if (password == null || password == ""){
      return Strings.passwordError;
    }

    if (password.length < 6 || password.length > 12){
      return Strings.passwordLengthError;
    }

    if (!password.contains(new RegExp(r'[A-Za-z]')) || !password.contains(new RegExp(r'[0-9]'))){
      return Strings.passwordTypeError;
    }

    return Strings.SUCCESS;
  }
}