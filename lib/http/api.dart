import 'dio_util.dart';
import 'index.dart';

class Api {
  static const String BASE_URL = "https://www.wanandroid.com";
  static const int ERROR_CODE_UN_LOGIN = -1001;
}

///账户相关接口
class AccountApi {
  static const String LOGIN_PATH = "/user/login";
  static const String REGIST_PATH = "/user/register";
  static const String LOGOUT_PATH = "/user/logout/json";

  static Future<Response> login(String username, String password) {
    return dio.post(LOGIN_PATH, queryParameters: {
      "username": username,
      "password": password,
    });
  }

  static Future<Response> regist(
      String username, String password, String repassword) {
    return dio.post(REGIST_PATH, queryParameters: {
      "username": username,
      "password": password,
      "repassword": repassword,
    });
  }

  static Future<Response> logout() {
    return dio.get(LOGOUT_PATH);
  }
}

class TodoApi {
  static const String ADD_TODO = "/lg/todo/add/json";

  static String UPDATE_TODO(int id) => "/lg/todo/update/$id/json";

  static String DELETE_TODO(int id) => "/lg/todo/delete/$id/json";

  static String UPDATE_TODO_STATUS(int id) => "/lg/todo/done/$id/json";

  static String TODO_LIST(int page) => "/lg/todo/v2/list/$page/json";

  static String dateFormat(DateTime date) {
    //yyyy-MM-dd
    String timestamp =
        "${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
//    String timestamp =
//        "${date.year.toString()}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";

    return timestamp;
  }

  //新增
  //title: 新增标题（必须）
  //	content: 新增详情（必须）
  //	date: 2018-08-01 预定完成时间（不传默认当天，建议传）
  //	type: 大于0的整数（可选）；
  //	priority 大于0的整数（可选）；
  static Future<Response> addTodo(
    String title,
    String content, {
    String completeDate,
    int type,
    int priority,
  }) {
    Map<String, dynamic> query = {
      'title': title,
      'content': content,
    };
    query['date'] = dateFormat(DateTime.now());
    if (completeDate != null) {
      query['completeDate'] = completeDate;
    }
    if (type != null) {
      query['type'] = type;
    }
    if (priority != null) {
      query['priority'] = priority;
    }
    return dio.post(ADD_TODO, queryParameters: query);
  }

  //更新
  //	id: 拼接在链接上，为唯一标识，列表数据返回时，每个todo 都会有个id标识 （必须）
  //	title: 更新标题 （必须）
  //	content: 新增详情（必须）
  //	date: 2018-08-01（必须）
  //	status: 0 // 0为未完成，1为完成
  //	type: ；
  //	priority: ；
  static Future<Response> updateTodo(
    int id,
    String title,
    String content,
    String date, {
    String completeDate,
    int status,
    int type,
    int priority,
  }) {
    Map<String, dynamic> query = {
      'title': title,
      'content': content,
    };
    if (date != null) {
      query['date'] = date;
    }
    if (completeDate != null) {
      query['completeDate'] = completeDate;
    }
    if (type != null) {
      query['type'] = type;
    }
    if (status != null) {
      query['status'] = status;
    }
    if (priority != null) {
      query['priority'] = priority;
    }
    return dio.post(UPDATE_TODO(id), queryParameters: query);
  }

  //删除
  //id: 拼接在链接上，为唯一标识
  static Future<Response> deleteTodo(int id) {
    return dio.post(DELETE_TODO(id));
  }

  //仅更新完成状态
  //id: 拼接在链接上，为唯一标识
  //	status: 0或1，传1代表未完成到已完成，反之则反之。
  static Future<Response> updateTodoStatus(int id, int status) {
    return dio.post(UPDATE_TODO_STATUS(id), queryParameters: {
      'status': status,
    });
  }

  //获取
  //	页码从1开始，拼接在url 上
  //	status 状态， 1-完成；0未完成; 默认全部展示；
  //	type 创建时传入的类型, 默认全部展示
  //	priority 创建时传入的优先级；默认全部展示
  //	orderby 1:完成日期顺序；2.完成日期逆序；3.创建日期顺序；4.创建日期逆序(默认)；
  static Future<Response> getTodoList(
    int page, {
    int status,
    int type,
    int priority,
    int orderby,
  }) {
    Map<String, dynamic> query = Map();
    if (type != null) {
      query['type'] = type;
    }
    if (status != null) {
      query['status'] = status;
    }
    if (priority != null) {
      query['priority'] = priority;
    }
    if (orderby != null) {
      query['orderby'] = orderby;
    }
    return dio.get(TODO_LIST(page), queryParameters: query);
  }
}
