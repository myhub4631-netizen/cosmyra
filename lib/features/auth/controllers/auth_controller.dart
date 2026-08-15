import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/supabase_config.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  if (!SupabaseConfig.isConfigured) {
    return const Stream.empty();
  }
  return supabase.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.session?.user ?? (SupabaseConfig.isConfigured ? supabase.auth.currentUser : null);
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthStateModel>((ref) {
  return AuthController(ref);
});

class AuthStateModel {
  final bool isLoading;
  final String? errorMessage;
  final bool isGuest;
  final String? guestEmail;
  final String? guestName;
  final String? guestPhone;
  final bool isAdmin;

  const AuthStateModel({
    this.isLoading = false,
    this.errorMessage,
    this.isGuest = false,
    this.guestEmail,
    this.guestName,
    this.guestPhone,
    this.isAdmin = false,
  });

  AuthStateModel copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isGuest,
    String? guestEmail,
    String? guestName,
    String? guestPhone,
    bool? isAdmin,
  }) {
    return AuthStateModel(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isGuest: isGuest ?? this.isGuest,
      guestEmail: guestEmail ?? this.guestEmail,
      guestName: guestName ?? this.guestName,
      guestPhone: guestPhone ?? this.guestPhone,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class AuthController extends StateNotifier<AuthStateModel> {
  final Ref ref;

  AuthController(this.ref) : super(const AuthStateModel()) {
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    if (!SupabaseConfig.isConfigured) return;
    final user = supabase.auth.currentUser;
    if (user != null) {
      final email = user.email?.trim().toLowerCase();
      if (email == '1mdollar2027@gmail.com' || email == 'admin@cosmyra.com' || email == 'admin@cosmyra.cloud') {
        state = state.copyWith(isAdmin: true);
        return;
      }
      try {
        final profile = await supabase.from('profiles').select('role').eq('id', user.id).maybeSingle();
        if (profile != null && (profile['role'] == 'admin' || profile['role'] == 'staff')) {
          state = state.copyWith(isAdmin: true);
        }
      } catch (_) {}
    }
  }

  void setGuestDetails({
    required String name,
    required String email,
    required String phone,
  }) {
    state = state.copyWith(
      isGuest: true,
      guestName: name,
      guestEmail: email,
      guestPhone: phone,
    );
  }

  Future<bool> signInWithEmail({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cleanEmail = email.trim();
      if (SupabaseConfig.isConfigured) {
        final res = await supabase.auth.signInWithPassword(email: cleanEmail, password: password);
        if (res.user != null) {
          final isMaster = cleanEmail.toLowerCase() == '1mdollar2027@gmail.com' ||
              cleanEmail.toLowerCase() == 'admin@cosmyra.com' ||
              cleanEmail.toLowerCase() == 'admin@cosmyra.cloud';
          await _checkAdminStatus();
          state = state.copyWith(
            isLoading: false,
            isGuest: false,
            isAdmin: isMaster ? true : state.isAdmin,
          );
          return true;
        } else {
          state = state.copyWith(isLoading: false, errorMessage: 'Invalid email or password.');
          return false;
        }
      }
      // Demo mode fallback only when Supabase API key is unconfigured
      final isMaster = cleanEmail.toLowerCase() == '1mdollar2027@gmail.com' ||
          cleanEmail.toLowerCase() == 'admin@cosmyra.com' ||
          cleanEmail.toLowerCase() == 'admin@cosmyra.cloud';
      state = state.copyWith(isLoading: false, isGuest: false, isAdmin: isMaster);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cleanEmail = email.trim();
      final isMaster = cleanEmail.toLowerCase() == '1mdollar2027@gmail.com' ||
          cleanEmail.toLowerCase() == 'admin@cosmyra.com' ||
          cleanEmail.toLowerCase() == 'admin@cosmyra.cloud';
      final userRole = isMaster ? 'admin' : 'customer';

      if (SupabaseConfig.isConfigured) {
        final res = await supabase.auth.signUp(
          email: cleanEmail,
          password: password,
          data: {'full_name': fullName, 'role': userRole},
        );
        if (res.user != null) {
          try {
            await supabase.from('profiles').upsert({
              'id': res.user!.id,
              'email': cleanEmail,
              'full_name': fullName,
              'role': userRole,
            });
          } catch (_) {}
          state = state.copyWith(isLoading: false, isGuest: false, isAdmin: isMaster);
          return true;
        } else {
          state = state.copyWith(isLoading: false, errorMessage: 'Registration failed. Please check your details.');
          return false;
        }
      }
      state = state.copyWith(isLoading: false, isGuest: false, isAdmin: isMaster);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    if (SupabaseConfig.isConfigured) {
      await supabase.auth.signOut();
    }
    state = const AuthStateModel();
  }

  void toggleAdminPreview(bool isAdmin) {
    state = state.copyWith(isAdmin: isAdmin);
  }
}
