//const serviceUrl = 'http://192.168.3.69:8080/api/v2/';
const serviceUrl = 'http://192.168.3.75:8080/api/v2/';

//const uploadImageUrl = 'http://192.168.3.69:8082/upload/image';
const uploadImageUrl = 'http://192.168.3.75:8082/upload/image';

//const uploadAudioUrl = 'http://192.168.3.69:8082/upload/audio';
const uploadAudioUrl = 'http://192.168.3.75:8082/upload/audio';

const allUrl = {
  'getGameInfo': serviceUrl + 'game/base', // 获取游戏名称、大区、段位、模式基础数据

  'user_info': serviceUrl + 'user/info', // 查看个人用户信息
  'mobileLogin': serviceUrl + 'passport/mobile/login', // 手机登录
  'accountLogin': serviceUrl + 'passport/account/login', // 账号密码登录
  'send': serviceUrl + 'sms/send', // 发送验证码短信
  'register': serviceUrl + 'passport/register', // 手机注册
  'passwordReset': serviceUrl + 'passport/password/reset', // 重置密码
  'unreadMessageNum': serviceUrl + 'user/message/unreadnum', // 未读消息数
  'user_recent_contacts': serviceUrl + 'user/recently/contact', // GET 最近联系人列表
  'group_user_recent_contacts': serviceUrl + 'groups/user/recently/contact', // GET 最近联系人列表  单聊群聊
  'friendList': serviceUrl + 'user/friend/list', // 好友列表
  'search_user': serviceUrl + 'user/search', // 搜索好友
  'userMessage': serviceUrl + 'user/message/list', // 聊天记录
  'voiceToWord': serviceUrl + 'util/voiceToWord', // 语音消息翻译
//  'userPublicInfo': serviceUrl + 'user/public/info', // 查看用户信息
  'userPublicInfo': serviceUrl + 'room/user/info', // 查看其他用户信息（含游戏资料卡）
  'systemMessages': serviceUrl + 'user/system/message/list', // 获取系统消息（消息助手）
  'addGroup': serviceUrl + 'groups/add', // 创建群聊
  'groups': serviceUrl + 'groups/join/list', // 获取用户群聊
  'leigodLogin': serviceUrl + 'passport/leigod/login', // 雷神登录
  'checkRegister': serviceUrl + 'passport/mobile/register/check', // 验证手机是否注册
  'oauthBindPhone': serviceUrl + 'passport/oauth/mobile/bind', // 第三方绑定手机
  'groupMessages': serviceUrl + 'groups/message/list', // 群聊天记录
  'groupMember': serviceUrl + 'groups/user/list', // 群成员
  'systemNotice': serviceUrl + 'system/notice/list', // 系统公告
  'clearGroupClear': serviceUrl + 'groups/clear/chat', // 清空群聊记录
  'user_information': serviceUrl + 'user/info/update', // 更新用户信息
  'updateUserExtend': serviceUrl + 'user/extend/update', // 修改用户扩展信息-- 用户状态--好友验证类型
  'userExtendInfo': serviceUrl + 'user/extend/info', // 获取用户扩展信息
  'untying_phone': serviceUrl + 'passport/mobile/check', // 更换绑定手机号-发送验证码
  'change_phone': serviceUrl + 'passport/mobile/change', // 更换绑定手机号
  'ignore_all_system_messages': serviceUrl + 'user/system/message/ignore', // 清空消息助手所有消息
  'systemNoticeDetail': serviceUrl + 'system/notice/detail', // 系统公告详情
  'updateUserRemark': serviceUrl + 'user/friend/remark/update', // 修改好友备注
  'nickname_exist': serviceUrl + 'passport/nickname/exist', // 检查昵称是否存在
  'oauthLogin': serviceUrl + 'passport/oauth/app/login', // 第三方登录
  'geestFirst': serviceUrl + 'gt/preprocess?t=', // 第三方登录

  'gameList': serviceUrl + 'room/search', // 游戏列表
  'createRoom': serviceUrl + 'room/add', // 创建房间
  'userInfo': serviceUrl + 'user/info', // 个人信息
  'quickDating': serviceUrl + 'room/speed/dating', // 快速匹配
  'gameCardList': serviceUrl + 'game/card/base', // 获取游戏卡片数据
  'addCard': serviceUrl + 'game/card/add', // 添加游戏卡片
  'userCard': serviceUrl + 'game/card/list', // 获取用户游戏卡片
  'editCard': serviceUrl + 'game/card/edit', // 编辑用户游戏卡片
  'deleteCard': serviceUrl + 'game/card/delete', // 删除用户游戏卡片
  'getRoomName': serviceUrl + 'room/random/name', // 获取随机房间名称
  'bannerList': serviceUrl + 'banner/list', // 首页banner
  'getUserInfo': serviceUrl + 'room/user/info', /// 获取用户信息
  'appVersion': serviceUrl + 'version', /// 获取最新app版本
  'lookUser': serviceUrl + 'room/look/user', /// 获取用户列表
};