import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  Future<AuthResponse?> signUp(String email, String password) async {
    try {
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } on AuthException {
      return null;
    } catch (error) {
      return null;
    }
  }

  Future<AuthResponse?> signIn(String email, String password) async {
    try {
      final AuthResponse response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      print(response);
      return response;
    } on AuthException {
      return null;
    } catch (error) {
      return null;
    }
  }
}
