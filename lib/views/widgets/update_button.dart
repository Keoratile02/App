import 'package:flutter/material.dart';

class UpdateButton extends StatelessWidget {
  final VoidCallback onUpdate;

  UpdateButton({required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onUpdate,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple, // Set button color to purple
      ),
      child: const Text(
        'Update Details',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
