import 'strings_zh.dart';

///当前语言：中文
Strings _res = StringsZh();

Strings get res => _res;

///语言集接口。方便统一管理字符串。也为未来多语言做准备
///ps:实际开发中发现，这样写无法赋值方法默认值（因为默认值要求为const）
abstract class Strings {
  //'get'关键字可加可不加。加上的话能够快速跳转具体实现：快捷键option + command + 左键
  get appName;

  get username;

  get password;

  get regist;

  get login;

  get netConnectFailed;

  get rePassword;

  get todo;

  get createNew;

  get allEmpty;

  get work;

  get life;

  get play;

  get all;

  get important;

  get normal;

  get relaxed;

  get orderByCreateTime;

  get orderByFinishTime;

  get isLoading;

  get create;

  get title;

  get detail;

  get finishTime;

  get planFinishTime;

  get noTemplate;

  get getExpress;

  get repay;

  get readbook;

  get getExpressDetail;

  get repayDetail;

  get readbookDetail;

  get editor;

  get isBottomst;

  get confirm;

  get cancel;

  get ensureDelete;

  get markDone;

  get markUndo;

  get todoTips;

  get pullToRefresh;

  get pullToRetry;

  get searchTips;

  get project;

  get ensureLogout;

  get logout;

  get newestProject;

  get article;

  get vxArticle;

  get navigation;

  get collect;

  get typeLevel1;

  get typeLevel2;

  get newestArticle;

  get author;

  get time;

  get QA;

  get New;

  get undone;

  get done;

  get openBrowser;

  get about;

  get feedback;

  get supportAuthor;

}

///通用的语言，直接这里实现。
///非通用的语言，各自子类继承它来实现。如中文语言：[StringsZh]
abstract class BaseStrings implements Strings {
  @override
  get appName => 'WanAndroid';
}
