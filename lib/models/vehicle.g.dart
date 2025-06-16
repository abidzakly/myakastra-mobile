// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vehicle _$VehicleFromJson(Map<String, dynamic> json) => Vehicle(
      json['id'] as String?,
      json['userId'] as String?,
      json['kilometer'] as String?,
      json['model'] as String?,
      json['nomor_polisi'] as String?,
      json['tipe_bensin'] as String?,
      json['transmisi'] as String?,
      const TimestampConverter().fromJson(json['createdAt']),
    );

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'kilometer': instance.kilometer,
      'model': instance.model,
      'nomor_polisi': instance.nomorPolisi,
      'tipe_bensin': instance.tipeBensin,
      'transmisi': instance.transmisi,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
