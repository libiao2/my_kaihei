class AuthorizationEvent{
  int type;

  AuthorizationEvent({this.type});
}

class AuthorizationType{
  static const int SUCCESS = 1;
  static const int FAILURE = 0;
}