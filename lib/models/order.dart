import 'package:json_annotation/json_annotation.dart';
import 'package:my_akastra_app/enums.dart';

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
  final DateTime? scheduledDate;
  @JsonKey(name: 'scheduled_time')
  final String? scheduledTime;
  @JsonKey(name: 'userId')
  final String? userId;
  @JsonKey(name: 'vehicle_id')
  final String? vehicleId;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  Order(
    this.id,
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
