import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  final String email;
  const ProfilePage({super.key, required this.email});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditMode = false;

  String name = 'Keoratile Bopalamo';
  String role = 'Software Developer';
  String email = 'mini@gmail.com';
  String phoneNumber = '072 123 1234';

  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController roleController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  File? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: name);
    roleController = TextEditingController(text: role);
    emailController = TextEditingController(text: email);
    phoneController = TextEditingController(text: phoneNumber);
  }

  @override
  void dispose() {
    nameController.dispose();
    roleController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _toggleEditMode() {
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        name = nameController.text;
        role = roleController.text;
        email = emailController.text;
        phoneNumber = phoneController.text;
        isEditMode = false;
      });
    }
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon, color: Colors.purple),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  Widget _buildEditField(
    IconData icon,
    String label,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.purple),
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text(
          'Profile Page',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isEditMode ? Icons.check : Icons.edit,
              color: Colors.white,
            ),
            onPressed: isEditMode ? _saveProfile : _toggleEditMode,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: isEditMode ? _pickImage : null,
              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                    _image != null
                        ? FileImage(_image!)
                        : const NetworkImage(
                              'https://www.gravatar.com/avatar/placeholder',
                            )
                            as ImageProvider,
                child:
                    _image == null
                        ? const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.white,
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child:
                  isEditMode
                      ? Column(
                        children: [
                          _buildEditField(Icons.person, 'Name', nameController),
                          const SizedBox(height: 10),
                          _buildEditField(Icons.work, 'Role', roleController),
                          const SizedBox(height: 10),
                          _buildEditField(
                            Icons.email,
                            'Email',
                            emailController,
                          ),
                          const SizedBox(height: 10),
                          _buildEditField(
                            Icons.phone,
                            'Phone',
                            phoneController,
                          ),
                        ],
                      )
                      : Column(
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            role,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const Divider(height: 40),
                          _buildInfoTile(Icons.email, 'Email', email),
                          _buildInfoTile(Icons.phone, 'Phone', phoneNumber),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
