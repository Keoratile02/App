import 'package:firebase_flutter/viewmodels/profile_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the ProfileViewModel and listen for changes
    final profileViewModel = Provider.of<ProfileViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Profile Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${profileViewModel.name}"),
            Text("Role: ${profileViewModel.role}"),
            Text("Email: ${profileViewModel.email}"),
            Text("Phone: ${profileViewModel.phoneNumber}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Update profile information
                profileViewModel.updateName("Bhelekazi");
                profileViewModel.updateRole("Lecturer");
                profileViewModel.updateEmail("bhelekazi@cut.ac.za");
                profileViewModel.updatePhoneNumber("051-507-5555");
                // Show a confirmation message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Profile updated successfully!"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text("Update Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
