import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/student_register_viewmodel.dart';

class StudentRegisterScreen extends StatelessWidget {
  const StudentRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StudentRegisterViewModel(),
      child: Consumer<StudentRegisterViewModel>(
        builder:
            (context, vm, _) => Scaffold(
              appBar: AppBar(
                title: const Text('Student Registration'),
                centerTitle: true,
                backgroundColor: Colors.purple,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Form(
                  key: vm.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Create Your Student Account",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      TextFormField(
                        controller: vm.nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => vm.validateField(value, 'Name'),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: vm.studentIdController,
                        decoration: const InputDecoration(
                          labelText: 'Student ID',
                          prefixIcon: Icon(Icons.badge),
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) => vm.validateField(value, 'Student ID'),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: vm.contactController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Number',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (value) => vm.validateField(value, 'Contact'),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: vm.emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: vm.validateEmail,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: vm.passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        validator: vm.validatePassword,
                      ),
                      const SizedBox(height: 20),

                      if (vm.errorMessage != null)
                        Text(
                          vm.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),

                      const SizedBox(height: 20),

                      vm.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                            icon: const Icon(Icons.app_registration),
                            label: const Text('Register'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              if (vm.formKey.currentState?.validate() ??
                                  false) {
                                vm.setLoading(true);
                                final success = await vm.registerStudent();
                                vm.setLoading(false);

                                if (success && context.mounted) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/home',
                                  );
                                } else if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        vm.errorMessage ??
                                            'Registration failed',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
