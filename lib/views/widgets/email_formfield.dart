import 'package:flutter/material.dart';

class EmailFormfield extends StatelessWidget {
  const EmailFormfield({super.key, 
    
    required TextEditingController emailController,
  }) : _emailController = emailController;

  final TextEditingController _emailController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(labelText: 'Email'),
      validator: (value) {
        // Validate email format
        if (value == null ||
            value.isEmpty ||
            !value.trim().endsWith('@cut.ac.za')) {
          return 'Please enter a valid CUT email address';
        }
        return null;
      },
    );
  }
}
