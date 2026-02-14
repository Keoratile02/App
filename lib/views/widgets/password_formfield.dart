import 'package:flutter/material.dart';

class PasswordFormField extends StatelessWidget {
  const PasswordFormField({super.key, 
    
    required TextEditingController passwordController,
  }) : _passwordController = passwordController;

  final TextEditingController _passwordController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(labelText: 'Password'),
      obscureText: true,
      /* validator: (value) {
        // Validate password format
        if (value == null ||
            value.isEmpty ||
            value.trim().length < 8 ||
            !value.trim().contains('@')) {
          return 'Password must be at least 8 characters long and contain "@" symbol';
        }
        return null;
      },*/
    );
  }
}
