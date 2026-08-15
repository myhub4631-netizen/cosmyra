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
      if (user.email?.trim().toLowerCase() == '1mdollar2027@gmail.com' ||
          user.email?.trim().toLowerCase() == 'admin@cosmyra.com' ||
          user.email?.trim().toLowerCase() == 'admin@cosmyra.cloud') {
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
      final isMasterAdmin = email.trim().toLowerCase() == '1mdollar2027@gmail.com' ||
          email.trim().toLowerCase() == 'admin@cosmyra.com' ||
          email.trim().toLowerCase() == 'admin@cosmyra.cloud';

      if (SupabaseConfig.isConfigured) {
        await supabase.auth.signInWithPassword(email: email, password: password);
        await _checkAdminStatus();
      }
      state = state.copyWith(isLoading: false, isGuest: false, isAdmin: isMasterAdmin ? true : state.isAdmin);
      return true;
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
      final isMasterAdmin = email.trim().toLowerCase() == '1mdollar2027@gmail.com' ||
          email.trim().toLowerCase() == 'admin@cosmyra.com' ||
          email.trim().toLowerCase() == 'admin@cosmyra.cloud';
      final userRole = isMasterAdmin ? 'admin' : 'customer';

      if (SupabaseConfig.isConfigured) {
        final res = await supabase.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': fullName},
        );
        if (res.user != null) {
          await supabase.from('profiles').upsert({
            'id': res.user!.id,
            'email': email,
            'full_name': fullName,
            'role': userRole,
          });
        }
      }
      state = state.copyWith(isLoading: false, isGuest: false, isAdmin: isMasterAdmin ? true : state.isAdmin);
      return true;
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
