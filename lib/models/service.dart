import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';

import 'package:my_akastra_app/enums.dart';

part 'service.g.dart';

Service serviceFromJson(String str) => Service.fromJson(json.decode(str));

String serviceToJson(Service data) => json.encode(data.toJson());

@JsonSerializable()
class Service {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "label")
  final String? label;
  @JsonKey(name: "price")
  final int? price;
  @JsonKey(name: "service_type")
  final ServiceType? serviceType;

  Service({
    this.id,
    this.label,
    this.price,
    this.serviceType,
  });

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}
