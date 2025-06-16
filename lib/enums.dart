import 'package:json_annotation/json_annotation.dart';

enum ServiceType {
  @JsonValue('SERVIS_BERKALA')
  servisBerkala(
    label: 'Servis Berkala',
    value: 'SERVIS_BERKALA',
  ),

  @JsonValue('BODY_CAT')
  bodyCat(
    label: 'Body & Cat',
    value: 'BODY_CAT',
  ),

  @JsonValue('GANTI_OLI')
  gantiOli(
    label: 'Ganti Oli',
    value: 'GANTI_OLI',
  ),

  @JsonValue('SERVIS_UMUM')
  servisUmum(
    label: 'Servis Umum',
    value: 'SERVIS_UMUM',
  );

  const ServiceType({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

enum OrderStatus {
  @JsonValue('IN_PROGRESS')
  inProgress(
    label: 'Proses Pengerjaan',
    value: 'IN_PROGRESS',
  ),

  @JsonValue('DONE')
  done(
    label: 'Selesai',
    value: 'DONE',
  ),

  @JsonValue('WAITING')
  waiting(
    label: 'Menunggu',
    value: 'WAITING',
  );

  const OrderStatus({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

enum ScheduleTime {
  @JsonValue('08:00')
  eight(
    label: '08:00',
  ),

  @JsonValue('09:00')
  nine(
    label: '09:00',
  ),

  @JsonValue('10:00')
  ten(
    label: '10:00',
  ),

  @JsonValue('11:00')
  eleven(
    label: '11:00',
  ),

  @JsonValue('12:00')
  twelve(
    label: '12:00',
  ),

  @JsonValue('13:00')
  thirteen(
    label: '13:00',
  ),

  @JsonValue('14:00')
  fourteen(
    label: '14:00',
  ),

  @JsonValue('15:00')
  fifteen(
    label: '15:00',
  ),

  @JsonValue('16:00')
  sixteen(
    label: '16:00',
  );

  const ScheduleTime({
    required this.label,
  });

  final String label;
}
