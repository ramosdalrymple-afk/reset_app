import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback toggleScreens;

  const LoginPage({super.key, required this.toggleScreens});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // NEW: Handle Google Login
  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    final result = await AuthService().signInWithGoogle();

    if (mounted) setState(() => _isLoading = false);

    if (result != "Success") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result ?? "Google Sign-In failed")),
      );
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await AuthService().login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) setState(() => _isLoading = false);

      if (result != "Success") {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result ?? "An error occurred")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Added Center for better desktop layout
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ), // Professional desktop width
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: _emailController,
                  hintText: "Email",
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _passwordController,
                  hintText: "Password",
                  obscureText: true,
                ),
                const SizedBox(height: 30),

                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        children: [
                          // Standard Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Login"),
                            ),
                          ),

                          const SizedBox(height: 15),
                          const Text("OR"),
                          const SizedBox(height: 15),

                          // NEW: Google Sign-In Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: _handleGoogleLogin,
                              icon: Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                                height: 24,
                              ),
                              label: const Text("Continue with Google"),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                foregroundColor: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: widget.toggleScreens,
                  child: const Text("Don't have an account? Register now"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
