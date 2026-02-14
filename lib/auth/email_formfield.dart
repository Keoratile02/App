import 'package:flutter/material.dart';

class EmailFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const EmailFormField({
    super.key,
    required this.controller,
    this.label = 'CUT Email',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.email),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email is required';
        }
        if (!value.trim().toLowerCase().endsWith('@cut.ac.za')) {
          return 'Only CUT emails allowed';
        }
        return null;
      },
    );
  }
}
