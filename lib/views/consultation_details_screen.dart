import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_consultation_screen.dart'; // Make sure this import is correct

class ConsultationDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> consultation;
  final String bookingId;
  final VoidCallback onDelete;

  const ConsultationDetailsScreen({
    super.key,
    required this.consultation,
    required this.bookingId,
    required this.onDelete,
  });

  // Show confirmation dialog before deleting
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Consultation"),
            content: const Text(
              "Are you sure you want to delete this consultation?",
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close dialog
                  onDelete();
                  Navigator.of(context).pop(); // close details screen
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  String _formatDateTime(Timestamp timestamp) {
    final dt = timestamp.toDate();
    final formattedDate = DateFormat.yMMMMd().format(dt);
    final formattedTime = DateFormat.jm().format(dt);
    return "$formattedDate at $formattedTime";
  }

  @override
  Widget build(BuildContext context) {
    final lecturer = consultation['lecturer'] ?? 'Unknown';
    final topic = consultation['topic'] ?? 'No Topic';
    final notes = consultation['notes'] ?? 'No Notes';
    final timestamp = consultation['date'] as Timestamp?;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Consultation Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Lecturer: $lecturer", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            if (timestamp != null)
              Text(
                "Date & Time: ${_formatDateTime(timestamp)}",
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 10),
            Text("Topic: $topic", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Notes: $notes", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => AddConsultationScreen(
                              existingBooking: consultation,
                              bookingId: bookingId,
                            ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                    "Edit",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showDeleteConfirmationDialog(context),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text(
                    "Delete",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: const Text(
                  "Back to Home",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
