// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hot_key_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotKeyEntity _$HotKeyEntityFromJson(Map<String, dynamic> json) {
  return HotKeyEntity(
    json['id'] as int,
    json['link'] as String,
    json['name'] as String,
    json['order'] as int,
    json['visible'] as int,
  );
}

Map<String, dynamic> _$HotKeyEntityToJson(HotKeyEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'link': instance.link,
      'name': instance.name,
      'order': instance.order,
      'visible': instance.visible,
    };
