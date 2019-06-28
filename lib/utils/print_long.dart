///print打印日志有长度限制，超出部分会自动别截断。
///本方法可以打印长日志。

///经测试，print一次最多打印1023长度。大部分中文占3字节。因此使用最保险的最大长度 1023 / 3 = 341
///同时这也说明如果日志里没有中文或只有部分中文时，直接用print其实是比printLong一次打印更多内容的，
///所以你日常打印还是应该尽量用print，只有真的不确定打印会不会很多时再用printLong
int maxLength = 340;

void printLong(String log) {
  if (log.length < maxLength) {
    print(log);
  } else {
    while (log.length > maxLength) {
      print(log.substring(0, maxLength));
      log = log.substring(maxLength);
    }
    //打印剩余部分
    print(log);
  }
}
