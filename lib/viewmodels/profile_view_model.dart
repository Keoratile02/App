import 'package:flutter/material.dart';

class ProfileViewModel extends ChangeNotifier {
  String _name;
  String _role;
  String _email;
  String _phoneNumber;

  ProfileViewModel({
    String name = 'John Doe',
    String role = 'Student',
    String email = 'john.doe@example.com',
    String phoneNumber = '123-456-7890',
  }) : _name = name,
       _role = role,
       _email = email,
       _phoneNumber = phoneNumber;

  String get name => _name;
  String get role => _role;
  String get email => _email;
  String get phoneNumber => _phoneNumber;

  void updateName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void updateRole(String newRole) {
    _role = newRole;
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    _email = newEmail;
    notifyListeners();
  }

  void updatePhoneNumber(String newPhoneNumber) {
    _phoneNumber = newPhoneNumber;
    notifyListeners();
  }
}
