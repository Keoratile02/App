import 'package:flutter/material.dart';

class PasswordFormField extends StatefulWidget {
  final TextEditingController controller;
  const PasswordFormField({super.key, required this.controller});

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        value = value?.trim();
        if (value == null || value.isEmpty) return 'Password is required';
        if (value.length < 8) return 'Minimum 8 characters';
        if (!value.contains('@')) return 'Must contain @ symbol';
        return null;
      },
    );
  }
}
