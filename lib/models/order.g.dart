// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      json['id'] as String,
      json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      $enumDecodeNullable(_$OrderStatusEnumMap, json['order_status']),
      (json['ordered_service_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      json['scheduled_date'] == null
          ? null
          : DateTime.parse(json['scheduled_date'] as String),
      json['scheduled_time'] as String?,
      json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      json['userId'] as String?,
      json['vehicle_id'] as String?,
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'order_status': _$OrderStatusEnumMap[instance.orderStatus],
      'ordered_service_ids': instance.orderedServiceIds,
      'scheduled_date': instance.scheduledDate?.toIso8601String(),
      'scheduled_time': instance.scheduledTime,
      'userId': instance.userId,
      'vehicle_id': instance.vehicleId,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$OrderStatusEnumMap = {
  OrderStatus.inProgress: 'IN_PROGRESS',
  OrderStatus.done: 'DONE',
};
