// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      json['id'] as String,
      json['issue'] as String?,
      (json['total_bill'] as num?)?.toInt(),
      const TimestampConverter().fromJson(json['created_at']),
      $enumDecodeNullable(_$OrderStatusEnumMap, json['order_status']),
      (json['ordered_service_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      const TimestampConverter().fromJson(json['scheduled_date']),
      $enumDecodeNullable(_$ScheduleTimeEnumMap, json['scheduled_time']),
      const TimestampConverter().fromJson(json['updated_at']),
      json['userId'] as String?,
      json['vehicle_id'] as String?,
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': instance.id,
      'order_status': _$OrderStatusEnumMap[instance.orderStatus],
      'ordered_service_ids': instance.orderedServiceIds,
      'scheduled_date':
          const TimestampConverter().toJson(instance.scheduledDate),
      'scheduled_time': _$ScheduleTimeEnumMap[instance.scheduledTime],
      'userId': instance.userId,
      'vehicle_id': instance.vehicleId,
      'issue': instance.issue,
      'total_bill': instance.totalBill,
      'created_at': const TimestampConverter().toJson(instance.createdAt),
      'updated_at': const TimestampConverter().toJson(instance.updatedAt),
    };

const _$OrderStatusEnumMap = {
  OrderStatus.inProgress: 'IN_PROGRESS',
  OrderStatus.done: 'DONE',
  OrderStatus.waiting: 'WAITING',
};

const _$ScheduleTimeEnumMap = {
  ScheduleTime.eight: '08:00',
  ScheduleTime.nine: '09:00',
  ScheduleTime.ten: '10:00',
  ScheduleTime.eleven: '11:00',
  ScheduleTime.twelve: '12:00',
  ScheduleTime.thirteen: '13:00',
  ScheduleTime.fourteen: '14:00',
  ScheduleTime.fifteen: '15:00',
  ScheduleTime.sixteen: '16:00',
};
