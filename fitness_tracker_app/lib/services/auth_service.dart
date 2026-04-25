import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'database_helper.dart';
import 'security_service.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<UserModel?> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(OAuthProvider.google);
      final user = _supabase.auth.currentUser;
      if (user != null) {
        return await _syncUser(user);
      }
    } catch (error) {
      throw Exception('Google Sign-in failed: $error');
    }
    return null;
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {}
    await SecurityService.clearSession();
  }

  Future<UserModel?> getLoggedInUser() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await SecurityService.saveSession(user.id);
      return await _syncUser(user);
    }
    return null;
  }

  Future<UserModel?> loginLocal(String email, String password) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user != null) {
        await SecurityService.saveSession(res.user!.id);
        return await _syncUser(res.user!);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<UserModel?> registerLocal(String name, String email, String password) async {
    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (res.user != null) {
        if (res.session == null) {
          throw Exception('Please disable "Confirm email" in your Supabase Auth Settings.');
        }
        await SecurityService.saveSession(res.user!.id);
        return await _syncUser(res.user!);
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
    return null;
  }

  Future<UserModel> _syncUser(User supaUser) async {
    // Check if user exists in DB
    var existing = await DatabaseHelper.instance.getUserById(supaUser.id);
    if (existing == null) {
      final user = UserModel(
        id: supaUser.id,
        name: supaUser.userMetadata?['name'] ?? 'Unknown',
        email: supaUser.email ?? '',
        photoUrl: supaUser.userMetadata?['avatar_url'],
      );
      await DatabaseHelper.instance.saveUser(user);
      return user;
    }
    return existing;
  }
}
