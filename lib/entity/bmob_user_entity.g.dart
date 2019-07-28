// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bmob_user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BmobUserEntity _$BmobUserEntityFromJson(Map<String, dynamic> json) {
  return BmobUserEntity(
    json['userName'] as String,
    json['signature'] as String,
    json['level'] as int,
    json['strWhat'] as String,
    (json['numWhat'] as num)?.toDouble(),
  )
    ..createdAt = json['createdAt'] as String
    ..updatedAt = json['updatedAt'] as String
    ..objectId = json['objectId'] as String
    ..ACL = json['ACL'] as Map<String, dynamic>;
}

Map<String, dynamic> _$BmobUserEntityToJson(BmobUserEntity instance) =>
    <String, dynamic>{
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'objectId': instance.objectId,
      'ACL': instance.ACL,
      'userName': instance.userName,
      'signature': instance.signature,
      'level': instance.level,
      'strWhat': instance.strWhat,
      'numWhat': instance.numWhat,
    };
