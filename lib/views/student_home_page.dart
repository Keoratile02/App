import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_flutter/routes/app_router.dart';
import 'package:flutter/material.dart';

class StudentHomeScreen extends StatefulWidget {
  final String email;

  const StudentHomeScreen({super.key, required this.email});

  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? userEmail;
  String? userId;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    userEmail = user?.email ?? widget.email;
    userId = user?.uid;
  }

  Future<void> _refreshBookings() async {
    setState(() {}); // Triggers rebuild
  }

  Stream<QuerySnapshot> _bookingsStream() {
    return _firestore
        .collection('bookings')
        // .where('studentId', isEqualTo: userId)  // Uncomment if you want to filter at Firestore query level
        .orderBy('date', descending: true)
        .snapshots();
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _addConsultation() {
    Navigator.pushNamed(context, '/addConsultation');
  }

  void _goToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Adjust route if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Consultation Bookings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: _logout,
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBookings,
        child:
            userId == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userEmail != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Welcome, $userEmail 👋",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _bookingsStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text("No bookings found."),
                            );
                          }

                          final bookings = snapshot.data!.docs;

                          // Debug print all booking documents fetched
                          print("All bookings fetched (no filter):");
                          for (var doc in bookings) {
                            print("Booking ID: ${doc.id}, Data: ${doc.data()}");
                          }

                          // Filter bookings by userId manually for UI display
                          final userBookings =
                              bookings.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                return data['studentId'] == userId;
                              }).toList();

                          if (userBookings.isEmpty) {
                            return const Center(
                              child: Text("No bookings found for this user."),
                            );
                          }

                          final groupedBookings =
                              <String, List<QueryDocumentSnapshot>>{};

                          for (var doc in userBookings) {
                            final data = doc.data() as Map<String, dynamic>;
                            final date = _formatDate(data['date']);
                            groupedBookings
                                .putIfAbsent(date, () => [])
                                .add(doc);
                          }

                          return ListView(
                            children:
                                groupedBookings.entries.map((entry) {
                                  return ExpansionTile(
                                    title: Text(entry.key),
                                    children:
                                        entry.value.map((doc) {
                                          final data =
                                              doc.data()
                                                  as Map<String, dynamic>;
                                          final status = data['status'];
                                          final topic = data['topic'];
                                          final statusColor =
                                              status == 'confirmed'
                                                  ? Colors.green
                                                  : Colors.orange;

                                          return ListTile(
                                            title: Text(topic),
                                            subtitle: Text('Status: $status'),
                                            trailing: Icon(
                                              Icons.circle,
                                              color: statusColor,
                                              size: 12,
                                            ),
                                            onTap: () {
                                              final consultationData =
                                                  doc.data()
                                                      as Map<String, dynamic>;
                                              Navigator.pushNamed(
                                                context,
                                                RouteManager
                                                    .consultationDetails,
                                                arguments: {
                                                  'consultation':
                                                      consultationData,
                                                  'bookingId': doc.id,
                                                  'onDelete': () {
                                                    // Optional: Add your delete function here or leave empty
                                                  },
                                                },
                                              );
                                            },
                                          );
                                        }).toList(),
                                  );
                                }).toList(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addConsultation,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.purple,
        onTap: (index) {
          if (index == 1) _goToProfile();
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white),
            label: "Profile",
          ),
        ],
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.white,
      ),
    );
  }
}
