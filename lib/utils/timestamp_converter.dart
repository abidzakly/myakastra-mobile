import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class TimestampConverter implements JsonConverter<Timestamp?, dynamic> {
  const TimestampConverter();

  @override
  Timestamp? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json;
    // Handle if json is a Map (when decoding from Firestore)
    if (json is Map<String, dynamic> && json.containsKey('_seconds')) {
      return Timestamp(json['_seconds'], json['_nanoseconds'] ?? 0);
    }
    return null;
  }

  @override
  dynamic toJson(Timestamp? object) => object;
}