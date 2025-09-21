import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email, password, and username
  Future<AuthResponse> signUpWithEmailPassword({
    required String email,
    required String password,
    required String username,
  }) async {
    return await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
      },
    );
  }



  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get email of current user
  String? currentUserEmail() {
    final user = _supabase.auth.currentUser;
    return user?.email;
  }

  // Get username of current user
  String? currentUsername() {
    final user = _supabase.auth.currentUser;
    return user?.userMetadata?['username'] as String?;
  }

  List getCurrentUserDetails() {
    final SupabaseClient _supabase = Supabase.instance.client;
    final user = _supabase.auth.currentUser;
    final currentUserId = user?.id;
    final currentUserEmail = user?.email;
    final String? currentUsername = user?.userMetadata?['username'] as String?;
    final currentUserIdentities = _supabase.auth.currentUser?.identities;

    return [currentUserId, currentUserEmail, currentUsername, currentUserIdentities];
  }
}
