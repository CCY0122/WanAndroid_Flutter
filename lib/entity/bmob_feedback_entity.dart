import 'package:data_plugin/bmob/table/bmob_object.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bmob_feedback_entity.g.dart';

@JsonSerializable()
class BmobFeedbackEntity extends BmobObject{
  String userName;//用户名
  String feedback;


  BmobFeedbackEntity(this.userName, this.feedback);

  BmobFeedbackEntity.empty();


  factory BmobFeedbackEntity.fromJson(Map<String, dynamic> json) =>
      _$BmobFeedbackEntityFromJson(json);



  Map<String, dynamic> toJson() => _$BmobFeedbackEntityToJson(this);

  @override
  Map getParams() {
    return toJson();
  }

}