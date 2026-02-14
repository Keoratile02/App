import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  final String email;

  const AdminDashboardScreen({super.key, required this.email});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String searchStudentId = '';
  DateTime? startDate;
  DateTime? endDate;

  Stream<QuerySnapshot> getBookingsStream() {
    return FirebaseFirestore.instance.collection('bookings').snapshots();
  }

  bool dateInRange(DateTime bookingDate) {
    if (startDate != null && bookingDate.isBefore(startDate!)) return false;
    if (endDate != null && bookingDate.isAfter(endDate!)) return false;
    return true;
  }

  void deleteBooking(String docId) async {
    await FirebaseFirestore.instance.collection('bookings').doc(docId).delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Booking deleted')));
  }

  void confirmBooking(String docId) async {
    await FirebaseFirestore.instance.collection('bookings').doc(docId).update({
      'status': 'Confirmed',
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Booking confirmed')));
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
            tooltip: 'Logout',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Logged in as: ${widget.email}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Student ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => searchStudentId = value),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2026),
                  );
                  if (date != null) setState(() => startDate = date);
                },
                icon: const Icon(Icons.date_range),
                label: Text(
                  startDate == null
                      ? 'Start Date'
                      : DateFormat('yyyy-MM-dd').format(startDate!),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2026),
                  );
                  if (date != null) setState(() => endDate = date);
                },
                icon: const Icon(Icons.date_range),
                label: Text(
                  endDate == null
                      ? 'End Date'
                      : DateFormat('yyyy-MM-dd').format(endDate!),
                ),
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getBookingsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading bookings.'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final studentId = data['studentId'] ?? '';
                      final rawDate = data['date'];
                      DateTime bookingDate;

                      if (rawDate is Timestamp) {
                        bookingDate = rawDate.toDate();
                      } else if (rawDate is String) {
                        try {
                          bookingDate = DateTime.parse(rawDate);
                        } catch (_) {
                          return false;
                        }
                      } else {
                        return false;
                      }

                      return (searchStudentId.isEmpty ||
                              studentId.contains(searchStudentId)) &&
                          dateInRange(bookingDate);
                    }).toList();

                if (filtered.isEmpty) {
                  return const Center(child: Text('No bookings found.'));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final studentId = data['studentId'] ?? '';
                    final name = data['studentName'] ?? '';
                    final lecturer = data['lecturer'] ?? '';
                    final topic = data['topic'] ?? '';
                    final status = data['status'] ?? 'Pending';
                    final rawDate = data['date'];
                    String dateString;

                    if (rawDate is Timestamp) {
                      dateString = DateFormat(
                        'yyyy-MM-dd',
                      ).format(rawDate.toDate());
                    } else if (rawDate is String) {
                      dateString = rawDate;
                    } else {
                      dateString = 'Invalid date';
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          '$studentId - $name',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: $dateString'),
                            Text('Lecturer: $lecturer'),
                            Text('Topic: $topic'),
                            Text(
                              'Status: $status',
                              style: TextStyle(
                                color:
                                    status == 'Confirmed'
                                        ? Colors.green
                                        : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (status != 'Confirmed')
                              IconButton(
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () => confirmBooking(doc.id),
                                tooltip: 'Confirm Booking',
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed:
                                  () => showDialog(
                                    context: context,
                                    builder:
                                        (ctx) => AlertDialog(
                                          title: const Text("Delete Booking"),
                                          content: const Text(
                                            "Are you sure you want to delete this booking?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(ctx),
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                                deleteBooking(doc.id);
                                              },
                                              child: const Text("Delete"),
                                            ),
                                          ],
                                        ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
