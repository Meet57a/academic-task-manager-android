import 'package:academic_task_manager/pages/auth/signin.dart';
import 'package:academic_task_manager/pages/home.dart';
import 'package:academic_task_manager/services/auth_service.dart';
import 'package:academic_task_manager/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  AuthService authService = AuthService();

  Future<AuthResponse?> _signUp() async {
    final String email = username.text.trim();
    final String pass = password.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      showCustomSnackBar(context, "Please fill in all fields");
      return null;
    }
    final AuthResponse? response = await authService.signUp(email, pass);

    if (mounted) {
      if (response == null || response.user == null) {
        showCustomSnackBar(context, "Sign up failed. Please try again.");
        return null;
      }
      if (response.user != null) {
        showCustomSnackBar(context, "Sign up successful!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
    }
    return response;
  }

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Sign Up", style: TextStyle(fontSize: 25)),
              const Text(
                "Create an account, It's free",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: username,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withAlpha(25),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        label: const Text("Username"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: password,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withAlpha(25),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        label: const Text("Password"),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _signUp();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  backgroundColor: Colors.black,
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignIn()),
                      );
                    },
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
