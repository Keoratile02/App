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
      dateTime: (data['dateTime'] ?? data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'lecturer': lecturer,
      'topic': topic,
      'dateTime': Timestamp.fromDate(dateTime),
    };
  }
}
