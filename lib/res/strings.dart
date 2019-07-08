import 'strings_zh.dart';

///当前语言：中文
Strings _res = StringsZh();

Strings get res => _res;

///语言集接口。方便统一管理字符串。也为未来多语言做准备
abstract class Strings {
  //'get'关键字可加可不加。加上的话能够快速跳转具体实现：快捷键option + command + 左键
  get username;
  get password;
  get regist;
  get login;
  get netConnectFailed;
  get rePassword;
  get todo;
  get createNew;
  get allEmpty;
}

///通用的语言，直接这里实现。
///非通用的语言，各自子类继承它来实现。如中文语言：[StringsZh]
abstract class BaseStrings implements Strings {

}
