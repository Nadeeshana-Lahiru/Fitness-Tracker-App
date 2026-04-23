import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_helper.dart';

class AuthService {
  Future<UserModel?> signInWithGoogle() async {
    try {
      await GoogleSignIn.instance.initialize();
      final GoogleSignInAccount? account = await GoogleSignIn.instance.authenticate(
        scopeHint: ['email'],
      );
      if (account != null) {
        final user = UserModel(
          id: account.id,
          name: account.displayName ?? 'Unknown',
          email: account.email,
          photoUrl: account.photoUrl,
        );
        await DatabaseHelper.instance.saveUser(user);
        await _saveUserSession(user.id);
        return user;
      }
    } catch (error) {
      print("Google Sign in failed: $error");
      throw Exception('Google Sign-in failed. Check Web Client ID.');
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      print("Sign out error: $e");
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  Future<void> _saveUserSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<UserModel?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId != null) {
      return await DatabaseHelper.instance.getUser(userId);
    }
    return null;
  }

  Future<UserModel?> loginLocal(String email, String password) async {
    final user = await DatabaseHelper.instance.getUserByEmail(email);
    if (user != null && user.password == password) {
      await _saveUserSession(user.id);
      return user;
    }
    return null;
  }

  Future<UserModel?> registerLocal(String name, String email, String password) async {
    final existingUser = await DatabaseHelper.instance.getUserByEmail(email);
    if (existingUser != null) {
      throw Exception('Email already exists');
    }
    
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newUser = UserModel(
      id: id,
      name: name,
      email: email,
      password: password,
    );
    
    await DatabaseHelper.instance.saveUser(newUser);
    // Don't auto-login after register as requested: "after that go to the login page."
    return newUser;
  }
}
