import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  final String userId; // Firestore document ID (uid)
  final String email;
  final String name;
  final String studentId;
  final String contact;

  Profile({
    required this.userId,
    required this.email,
    required this.name,
    required this.studentId,
    required this.contact,
  });

  // Factory constructor to create Profile from Firestore doc snapshot
  factory Profile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Profile(
      userId: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      studentId: data['studentId'] ?? '',
      contact: data['contact'] ?? '',
    );
  }

  // Convert Profile object to Firestore data map for saving/updating
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'studentId': studentId,
      'contact': contact,
    };
  }
}
