class PatientRecord {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String date;
  final String diagnosis;
  final String prescription;
  final List<String> attachments;

  PatientRecord({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.diagnosis,
    required this.prescription,
    this.attachments = const [],
  });

  factory PatientRecord.fromMap(Map<String, dynamic> map) {
    return PatientRecord(
      id: map['_id'] ?? map['id'],
      patientId: map['patientId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      date: map['date'] ?? '',
      diagnosis: map['diagnosis'] ?? '',
      prescription: map['prescription'] ?? '',
      attachments: List<String>.from(map['attachments'] ?? []),
    );
  }
}
