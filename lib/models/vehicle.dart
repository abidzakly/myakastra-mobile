// To parse this JSON data, do
//
//     final vehicle = vehicleFromJson(jsonString);

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:my_akastra_app/utils/timestamp_converter.dart';

part 'vehicle.g.dart';

@JsonSerializable()
class Vehicle {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "userId")
  final String? userId;
  @JsonKey(name: "kilometer")
  final String? kilometer;
  @JsonKey(name: "model")
  final String? model;
  @JsonKey(name: "nomor_polisi")
  final String? nomorPolisi;
  @JsonKey(name: "tipe_bensin")
  final String? tipeBensin;
  @JsonKey(name: "transmisi")
  final String? transmisi;
  @JsonKey(name: "createdAt")
  @TimestampConverter()
  final Timestamp? createdAt;

  Vehicle(
    this.id,
    this.userId,
    this.kilometer,
    this.model,
    this.nomorPolisi,
    this.tipeBensin,
    this.transmisi,
    this.createdAt,
  );

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleToJson(this);
}
