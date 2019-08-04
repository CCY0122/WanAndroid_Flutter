// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bmob_update_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BmobUpdateEntity _$BmobUpdateEntityFromJson(Map<String, dynamic> json) {
  return BmobUpdateEntity(
    json['deviceType'] as int,
    json['versionName'] as String,
    json['updateMsg'] as String,
    json['downloadUrl'] as String,
  )
    ..createdAt = json['createdAt'] as String
    ..updatedAt = json['updatedAt'] as String
    ..objectId = json['objectId'] as String
    ..ACL = json['ACL'] as Map<String, dynamic>;
}

Map<String, dynamic> _$BmobUpdateEntityToJson(BmobUpdateEntity instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'objectId': instance.objectId,
      'ACL': instance.ACL,
      'deviceType': instance.deviceType,
      'versionName': instance.versionName,
      'updateMsg': instance.updateMsg,
      'downloadUrl': instance.downloadUrl,
    };
