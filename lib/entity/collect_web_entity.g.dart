// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collect_web_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectWebEntity _$CollectWebEntityFromJson(Map<String, dynamic> json) {
  return CollectWebEntity(
    json['desc'] as String,
    json['icon'] as String,
    json['id'] as int,
    json['link'] as String,
    json['name'] as String,
    json['order'] as int,
    json['userId'] as int,
    json['visible'] as int,
  );
}

Map<String, dynamic> _$CollectWebEntityToJson(CollectWebEntity instance) =>
    <String, dynamic>{
      'desc': instance.desc,
      'icon': instance.icon,
      'id': instance.id,
      'link': instance.link,
      'name': instance.name,
      'order': instance.order,
      'userId': instance.userId,
      'visible': instance.visible,
    };
