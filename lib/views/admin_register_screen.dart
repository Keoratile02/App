import 'package:firebase_flutter/viewmodels/admin_dashboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminRegisterScreen extends StatelessWidget {
  const AdminRegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminRegisterViewModel(),
      child: Consumer<AdminRegisterViewModel>(
        builder:
            (context, vm, _) => Scaffold(
              appBar: AppBar(
                title: const Text('Admin Registration'),
                centerTitle: true,
                backgroundColor: Colors.deepPurple,
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
                        "Create Admin Account",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      TextFormField(
                        controller: vm.emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: vm.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),

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
                      const SizedBox(height: 24),

                      if (vm.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            vm.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      vm.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                            icon: const Icon(Icons.admin_panel_settings),
                            label: const Text('Register as Admin'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
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
                                final success = await vm.registerAdmin();
                                vm.setLoading(false);

                                if (success && context.mounted) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/adminDashboard',
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
