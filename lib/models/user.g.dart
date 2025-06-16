// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      json['id'] as String?,
      json['email'] as String?,
      json['gender'] as String?,
      json['name'] as String?,
      json['phone'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'gender': instance.gender,
      'name': instance.name,
      'phone': instance.phone,
    };
