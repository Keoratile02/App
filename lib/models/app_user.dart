class AppUser {
  final String email;
  final String name;
  final String studentId;
  final String contact;
  final DateTime createdAt;
  final String role;

  AppUser({
    required this.email,
    required this.name,
    required this.studentId,
    required this.contact,
    required this.createdAt,
    required this.role,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'studentId': studentId,
      'contact': contact,
      'createdAt': createdAt.toIso8601String(),
      'role': role,
    };
  }

  factory AppUser.fromFirestore(Map<String, dynamic> data) {
    return AppUser(
      email: data['email'],
      name: data['name'],
      studentId: data['studentId'],
      contact: data['contact'],
      createdAt: DateTime.parse(data['createdAt']),
      role: data['role'],
    );
  }
}
