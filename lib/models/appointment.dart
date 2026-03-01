import 'package:healtime_app/models/doctor.dart';

class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final Doctor doctor;
  final String date;
  final String time;
  final String type;
  final String status;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctor,
    required this.date,
    required this.time,
    required this.type,
    required this.status,
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['_id'] ?? '',
      patientId: map['patientId'] is Map
          ? (map['patientId']['_id'] ?? '')
          : (map['patientId'] ?? ''),
      patientName: map['patientId'] is Map
          ? (map['patientId']['name'] ?? 'Patient')
          : 'Patient',
      doctor: Doctor.fromMap(map['doctorId']),
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      type: map['type'] ?? '',
      status: map['status'] ?? '',
    );
  }
}
