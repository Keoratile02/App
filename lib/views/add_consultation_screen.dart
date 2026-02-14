import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddConsultationScreen extends StatefulWidget {
  final Map<String, dynamic>? existingBooking;
  final String? bookingId;

  const AddConsultationScreen({
    super.key,
    this.existingBooking,
    this.bookingId,
  });

  @override
  _AddConsultationScreenState createState() => _AddConsultationScreenState();
}

class _AddConsultationScreenState extends State<AddConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _topicController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedLecturer;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> _lecturers = ['Dr. Smith', 'Prof. Jones'];

  @override
  void initState() {
    super.initState();
    if (widget.existingBooking != null) {
      final data = widget.existingBooking!;
      _selectedLecturer = data['lecturer'];
      final DateTime dateTime = (data['date'] as Timestamp).toDate();
      _selectedDate = dateTime;
      _selectedTime = TimeOfDay.fromDateTime(dateTime);
      _dateController.text = DateFormat.yMMMd().format(dateTime);
      _timeController.text = DateFormat.jm().format(dateTime);
      _topicController.text = data['topic'];
      _notesController.text = data['notes'];
    }
  }

  Future<void> _selectDate() async {
    DateTime now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat.yMMMd().format(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _saveConsultation() async {
    if (!_formKey.currentState!.validate() ||
        _selectedLecturer == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print("User ID is null");
      return;
    }

    final DateTime combinedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final data = {
      'studentId': userId,
      'lecturer': _selectedLecturer,
      'date': Timestamp.fromDate(combinedDateTime),
      'topic': _topicController.text.trim(),
      'notes': _notesController.text.trim(),
      'status': 'pending',
    };

    print("Saving booking with:");
    print("User ID: $userId");
    print("Lecturer: $_selectedLecturer");
    print("DateTime: $combinedDateTime");
    print("Topic: ${_topicController.text.trim()}");

    final bookings = FirebaseFirestore.instance.collection('bookings');

    try {
      if (widget.bookingId != null) {
        await bookings.doc(widget.bookingId).update(data);
        print("Booking updated.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final docRef = await bookings.add(data);
        print("Booking added with ID: ${docRef.id}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consultation booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      print("Error saving booking: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _topicController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bookingId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Booking' : 'Book Consultation'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedLecturer,
                items:
                    _lecturers
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (value) => setState(() => _selectedLecturer = value),
                decoration: const InputDecoration(
                  labelText: 'Select Lecturer *',
                ),
                validator:
                    (value) =>
                        value == null ? 'Please select a lecturer' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Date *'),
                onTap: _selectDate,
                validator:
                    (value) => value!.isEmpty ? 'Please pick a date' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Time *'),
                onTap: _selectTime,
                validator:
                    (value) => value!.isEmpty ? 'Please pick a time' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(labelText: 'Topic *'),
                validator: (value) {
                  if (value == null || value.trim().length < 20) {
                    return 'Topic must be at least 20 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveConsultation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  isEditing ? 'Update Booking' : 'Save Booking',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
