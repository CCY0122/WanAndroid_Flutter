// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bmob_feedback_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BmobFeedbackEntity _$BmobFeedbackEntityFromJson(Map<String, dynamic> json) {
  return BmobFeedbackEntity(
    json['userName'] as String,
    json['feedback'] as String,
  )
    ..createdAt = json['createdAt'] as String
    ..updatedAt = json['updatedAt'] as String
    ..objectId = json['objectId'] as String
    ..ACL = json['ACL'] as Map<String, dynamic>;
}

Map<String, dynamic> _$BmobFeedbackEntityToJson(BmobFeedbackEntity instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'objectId': instance.objectId,
      'ACL': instance.ACL,
      'userName': instance.userName,
      'feedback': instance.feedback,
    };
