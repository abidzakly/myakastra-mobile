import 'package:equatable/equatable.dart';
import 'package:my_akastra_app/enums.dart';
import 'package:my_akastra_app/models/service.dart';
import 'package:my_akastra_app/models/vehicle.dart';

class BookingData extends Equatable {
  final Vehicle? vehicle;
  final List<Service>? selectedServices;
  final DateTime? selectedDate;
  final ScheduleTime? selectedTime;
  final String? keluhan;

  const BookingData({
    this.vehicle,
    this.selectedServices,
    this.selectedDate,
    this.selectedTime,
    this.keluhan,
  });

  // CopyWith method for immutable updates
  BookingData copyWith({
    Vehicle? vehicle,
    List<Service>? selectedServices,
    DateTime? selectedDate,
    ScheduleTime? selectedTime,
    String? keluhan,
  }) {
    return BookingData(
      vehicle: vehicle ?? this.vehicle,
      selectedServices: selectedServices ?? this.selectedServices,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      keluhan: keluhan ?? this.keluhan,
    );
  }

  // Factory constructor for creating empty BookingData
  factory BookingData.empty() {
    return const BookingData();
  }

  // Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'vehicle': vehicle?.toJson(),
      'selectedServices': selectedServices?.map((service) => service.toJson()).toList(),
      'selectedDate': selectedDate?.toIso8601String(),
      'selectedTime': selectedTime?.toString(),
      'keluhan': keluhan,
    };
  }

  // Create from JSON for deserialization
  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      vehicle: json['vehicle'] != null ? Vehicle.fromJson(json['vehicle']) : null,
      selectedServices: json['selectedServices'] != null
          ? (json['selectedServices'] as List)
          .map((serviceJson) => Service.fromJson(serviceJson))
          .toList()
          : null,
      selectedDate: json['selectedDate'] != null
          ? DateTime.parse(json['selectedDate'])
          : null,
      selectedTime: json['selectedTime'] != null
          ? ScheduleTime.values.firstWhere(
            (e) => e.toString() == json['selectedTime'],
        orElse: () => ScheduleTime.values.first,
      )
          : null,
      keluhan: json['keluhan'],
    );
  }

  // Check if booking data is complete
  bool get isComplete {
    return vehicle != null &&
        selectedServices != null &&
        selectedServices!.isNotEmpty &&
        selectedDate != null &&
        selectedTime != null;
  }

  // Check if booking data is empty
  bool get isEmpty {
    return vehicle == null &&
        (selectedServices == null || selectedServices!.isEmpty) &&
        selectedDate == null &&
        selectedTime == null &&
        (keluhan == null || keluhan!.isEmpty);
  }

  // Get total service count
  int get serviceCount {
    return selectedServices?.length ?? 0;
  }

  // Get formatted date string
  String get formattedDate {
    if (selectedDate == null) return 'Belum dipilih';
    return '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';
  }

  // Get formatted time string
  String get formattedTime {
    if (selectedTime == null) return 'Belum dipilih';
    // You might want to customize this based on your ScheduleTime enum
    return selectedTime.toString().split('.').last;
  }

  @override
  List<Object?> get props => [
    vehicle,
    selectedServices,
    selectedDate,
    selectedTime,
    keluhan,
  ];

  @override
  String toString() {
    return 'BookingData(vehicle: $vehicle, selectedServices: $selectedServices, selectedDate: $selectedDate, selectedTime: $selectedTime, keluhan: $keluhan)';
  }
}