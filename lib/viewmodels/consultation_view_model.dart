// models/booking.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String studentId;
  final String studentName;
  final String lecturer;
  final String topic;
  final DateTime dateTime;

  Booking({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.lecturer,
    required this.topic,
    required this.dateTime,
  });

  factory Booking.fromMap(String id, Map<String, dynamic> data) {
    return Booking(
      id: id,
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      lecturer: data['lecturer'] ?? '',
      topic: data['topic'] ?? '',
      dateTime: (data['date'] as Timestamp).toDate(),
    );
  }
}
