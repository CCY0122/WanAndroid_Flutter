
class BaseEntity<T>{
  T data;
  int errorCode;
  String errorMsg;

  BaseEntity({this.data, this.errorCode, this.errorMsg});

  BaseEntity.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? json['data'] : null;
    errorCode = json['errorCode'];
    errorMsg = json['errorMsg'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    //泛型成员手动put进去
//    if (this.data != null) {
//      data['data'] = this.data.toJson();
//    }
    data['errorCode'] = this.errorCode;
    data['errorMsg'] = this.errorMsg;
    return data;
  }

  @override
  String toString() {
    return 'BaseEntity{data: $data, errorCode: $errorCode, errorMsg: $errorMsg}';
  }

}
