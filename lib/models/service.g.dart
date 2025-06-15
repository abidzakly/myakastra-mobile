// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Service _$ServiceFromJson(Map<String, dynamic> json) => Service(
      id: json['id'] as String?,
      label: json['label'] as String?,
      price: (json['price'] as num?)?.toInt(),
      serviceType:
          $enumDecodeNullable(_$ServiceTypeEnumMap, json['service_type']),
    );

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'price': instance.price,
      'service_type': _$ServiceTypeEnumMap[instance.serviceType],
    };

const _$ServiceTypeEnumMap = {
  ServiceType.servisBerkala: 'SERVIS_BERKALA',
  ServiceType.bodyCat: 'BODY_CAT',
  ServiceType.gantiOli: 'GANTI_OLI',
  ServiceType.servisUmum: 'SERVIS_UMUM',
};
