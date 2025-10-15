import 'package:academic_task_manager/pages/auth/signup.dart';
import 'package:academic_task_manager/pages/home.dart';
import 'package:academic_task_manager/services/auth_service.dart';
import 'package:academic_task_manager/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();

  final AuthService authService = AuthService();

  Future<AuthResponse?> _signIn() async {
    final String email = username.text.trim();
    final String pass = password.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      showCustomSnackBar(context, "Please fill in all fields");
      return null;
    }
    final AuthResponse? response = await authService.signIn(email, pass);
    if (mounted) {
      if (response == null || response.user == null) {
        showCustomSnackBar(context, "Sign in failed. Please try again.");
        return null;
      }
      if (response.user != null) {
        showCustomSnackBar(context, "Sign in successful!");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
          (route) => false,
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
              Text('Sign In', style: TextStyle(fontSize: 25)),
              Text(
                "Welcome back! Please sign in to your account.",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              SizedBox(height: 20),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: username,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withAlpha(25),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        label: Text("Username"),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: password,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.withAlpha(25),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        label: Text("Password"),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: AlignmentGeometry.centerRight,
                child: GestureDetector(
                  child: Text(
                    "Forget password?",
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _signIn();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  backgroundColor: Colors.black,
                ),
                child: Text(
                  "Sign In",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignUp()),
                      );
                    },
                    child: Text(
                      "Sign Up",
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
