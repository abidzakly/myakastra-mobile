import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:my_akastra_app/enums.dart';
import 'package:my_akastra_app/utils/timestamp_converter.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'order_status')
  final OrderStatus? orderStatus;
  @JsonKey(name: 'ordered_service_ids')
  final List<String>? orderedServiceIds;
  @JsonKey(name: 'scheduled_date')
  @TimestampConverter()
  final Timestamp? scheduledDate;
  @JsonKey(name: 'scheduled_time')
  final ScheduleTime? scheduledTime;
  @JsonKey(name: 'userId')
  final String? userId;
  @JsonKey(name: 'vehicle_id')
  final String? vehicleId;
  @JsonKey(name: 'issue')
  final String? issue;
  @JsonKey(name: 'total_bill')
  final int? totalBill;
  @JsonKey(name: 'created_at')
  @TimestampConverter()
  final Timestamp? createdAt;
  @JsonKey(name: 'updated_at')
  @TimestampConverter()
  final Timestamp? updatedAt;
  Order(
    this.id,
    this.issue,
    this.totalBill,
    this.createdAt,
    this.orderStatus,
    this.orderedServiceIds,
    this.scheduledDate,
    this.scheduledTime,
    this.updatedAt,
    this.userId,
    this.vehicleId,
  );

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
