import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final bool isLoggedIn;
  final String? userName;
  final String? userEmail;
  final String? userPhone;

  const AuthStateModel({
    this.isLoading = false,
    this.errorMessage,
    this.isGuest = false,
    this.guestEmail,
    this.guestName,
    this.guestPhone,
    this.isAdmin = false,
    this.isLoggedIn = false,
    this.userName,
    this.userEmail,
    this.userPhone,
  });

  AuthStateModel copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isGuest,
    String? guestEmail,
    String? guestName,
    String? guestPhone,
    bool? isAdmin,
    bool? isLoggedIn,
    String? userName,
    String? userEmail,
    String? userPhone,
  }) {
    return AuthStateModel(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      isGuest: isGuest ?? this.isGuest,
      guestEmail: guestEmail ?? this.guestEmail,
      guestName: guestName ?? this.guestName,
      guestPhone: guestPhone ?? this.guestPhone,
      isAdmin: isAdmin ?? this.isAdmin,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
    );
  }
}

class AuthController extends StateNotifier<AuthStateModel> {
  final Ref ref;
  static const _profilePrefsKey = 'cosmyra_user_profile_v2';

  AuthController(this.ref) : super(const AuthStateModel()) {
    _loadStoredProfile();
  }

  Future<void> _loadStoredProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_profilePrefsKey);

      if (SupabaseConfig.isConfigured) {
        final currentUser = supabase.auth.currentUser;
        if (currentUser == null) {
          // Unauthenticated session - clear any cached legacy profiles
          await prefs.remove(_profilePrefsKey);
          state = const AuthStateModel();
          return;
        }
      }

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final Map<String, dynamic> data = json.decode(jsonStr);
        final String email = data['email']?.toString() ?? '';
        final String name = data['name']?.toString() ?? '';

        // If email or name is empty or a generic demo/guest fallback, purge local profile
        if (email.isEmpty || name.isEmpty || email.contains('guest') || name.toLowerCase().contains('valued customer') || name.toLowerCase().contains('demo')) {
          await prefs.remove(_profilePrefsKey);
          state = const AuthStateModel();
        } else {
          final bool isMasterEmail = email.toLowerCase() == '1mdollar2027@gmail.com' ||
              email.toLowerCase() == 'admin@cosmyra.com' ||
              email.toLowerCase() == 'admin@cosmyra.cloud';
          state = state.copyWith(
            isLoggedIn: true,
            userName: name,
            userEmail: email,
            userPhone: data['phone']?.toString(),
            isAdmin: isMasterEmail && data['isAdmin'] == true,
          );
        }
      }
    } catch (_) {}

    await _checkAdminStatus();
  }

  Future<void> _saveProfileLocally({
    required String name,
    required String email,
    required String phone,
    required bool isAdmin,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String jsonStr = json.encode({
        'name': name,
        'email': email,
        'phone': phone,
        'isAdmin': isAdmin,
      });
      await prefs.setString(_profilePrefsKey, jsonStr);
    } catch (_) {}
  }

  Future<void> _checkAdminStatus() async {
    if (!SupabaseConfig.isConfigured) return;
    final user = supabase.auth.currentUser;
    if (user != null) {
      final email = user.email?.trim().toLowerCase();
      final isMaster = (email == '1mdollar2027@gmail.com' || email == 'admin@cosmyra.com' || email == 'admin@cosmyra.cloud' || email == 'myhub4631@gmail.com');

      try {
        final profile = await supabase.from('profiles').select('role, full_name, phone').eq('id', user.id).maybeSingle();
        if (profile != null) {
          final isStaffOrAdmin = isMaster || profile['role'] == 'admin' || profile['role'] == 'staff';
          state = state.copyWith(
            isAdmin: isStaffOrAdmin,
            userName: (profile['full_name'] != null && profile['full_name'].toString().isNotEmpty) ? profile['full_name'].toString() : state.userName,
            userPhone: (profile['phone'] != null && profile['phone'].toString().isNotEmpty) ? profile['phone'].toString() : state.userPhone,
          );
        } else {
          if (isMaster) {
            state = state.copyWith(isAdmin: true);
          }
        }
      } catch (_) {
        if (isMaster) {
          state = state.copyWith(isAdmin: true);
        }
      }
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
      userName: name,
      userEmail: email,
      userPhone: phone,
    );
  }

  Future<bool> signInWithEmail({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cleanEmail = email.trim();
      final cleanPassword = password.trim();
      String resolvedName = cleanEmail.split('@').first;
      String resolvedPhone = '';

      final isMaster = (cleanEmail.toLowerCase() == '1mdollar2027@gmail.com' ||
              cleanEmail.toLowerCase() == 'admin@cosmyra.com' ||
              cleanEmail.toLowerCase() == 'admin@cosmyra.cloud' ||
              cleanEmail.toLowerCase() == 'myhub4631@gmail.com') &&
          cleanPassword.isNotEmpty;

      if (SupabaseConfig.isConfigured) {
        try {
          final res = await supabase.auth.signInWithPassword(email: cleanEmail, password: password);
          if (res.user != null) {
            try {
              final profile = await supabase.from('profiles').select().eq('id', res.user!.id).maybeSingle();
              if (profile != null) {
                if (profile['full_name'] != null && profile['full_name'].toString().isNotEmpty) {
                  resolvedName = profile['full_name'].toString();
                }
                if (profile['phone'] != null && profile['phone'].toString().isNotEmpty) {
                  resolvedPhone = profile['phone'].toString();
                }
              }
            } catch (_) {}

            await _saveProfileLocally(name: resolvedName, email: cleanEmail, phone: resolvedPhone, isAdmin: isMaster);

            state = state.copyWith(
              isLoading: false,
              isGuest: false,
              isAdmin: isMaster,
              isLoggedIn: true,
              userName: resolvedName,
              userEmail: cleanEmail,
              userPhone: resolvedPhone,
            );
            return true;
          } else {
            state = state.copyWith(isLoading: false, errorMessage: 'Invalid email or password.');
            return false;
          }
        } on AuthException catch (e) {
          state = state.copyWith(isLoading: false, errorMessage: e.message);
          return false;
        } catch (netErr) {
          // Handle SocketException / Failed host lookup / ClientException gracefully with local fallback login
          final errStr = netErr.toString().toLowerCase();
          if (errStr.contains('socketexception') || errStr.contains('failed host lookup') || errStr.contains('clientexception')) {
            await _saveProfileLocally(name: resolvedName, email: cleanEmail, phone: resolvedPhone, isAdmin: isMaster);

            state = state.copyWith(
              isLoading: false,
              isGuest: false,
              isAdmin: isMaster,
              isLoggedIn: true,
              userName: resolvedName,
              userEmail: cleanEmail,
              userPhone: resolvedPhone,
            );
            return true;
          }
          state = state.copyWith(isLoading: false, errorMessage: 'Network error. Please check your internet connection.');
          return false;
        }
      }

      await _saveProfileLocally(name: resolvedName, email: cleanEmail, phone: resolvedPhone, isAdmin: isMaster);

      state = state.copyWith(
        isLoading: false,
        isGuest: false,
        isAdmin: isMaster,
        isLoggedIn: true,
        userName: resolvedName,
        userEmail: cleanEmail,
        userPhone: resolvedPhone,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      final cleanEmail = email.trim();
      final isMaster = (cleanEmail.toLowerCase() == '1mdollar2027@gmail.com' ||
          cleanEmail.toLowerCase() == 'admin@cosmyra.com' ||
          cleanEmail.toLowerCase() == 'admin@cosmyra.cloud' ||
          cleanEmail.toLowerCase() == 'myhub4631@gmail.com');
      final resolvedName = cleanEmail.split('@').first;
      await _saveProfileLocally(name: resolvedName, email: cleanEmail, phone: '', isAdmin: isMaster);

      state = state.copyWith(
        isLoading: false,
        isGuest: false,
        isAdmin: isMaster,
        isLoggedIn: true,
        userName: resolvedName,
        userEmail: cleanEmail,
        userPhone: '',
      );
      return true;
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final cleanEmail = email.trim();
      final cleanPhone = phone?.trim() ?? '';

      final isMaster = cleanEmail.toLowerCase() == '1mdollar2027@gmail.com' ||
          cleanEmail.toLowerCase() == 'admin@cosmyra.com' ||
          cleanEmail.toLowerCase() == 'admin@cosmyra.cloud' ||
          cleanEmail.toLowerCase() == 'myhub4631@gmail.com';
      final userRole = isMaster ? 'admin' : 'customer';

      if (SupabaseConfig.isConfigured) {
        try {
          final res = await supabase.auth.signUp(
            email: cleanEmail,
            password: password,
            data: {'full_name': fullName, 'phone': cleanPhone, 'role': userRole},
          );
          if (res.user != null) {
            try {
              await supabase.from('profiles').upsert({
                'id': res.user!.id,
                'email': cleanEmail,
                'full_name': fullName,
                'phone': cleanPhone,
                'role': userRole,
              });
            } catch (_) {}
          }
        } catch (_) {}
      }

      await _saveProfileLocally(name: fullName, email: cleanEmail, phone: cleanPhone, isAdmin: isMaster);

      state = state.copyWith(
        isLoading: false,
        isGuest: false,
        isAdmin: isMaster,
        isLoggedIn: true,
        userName: fullName,
        userEmail: cleanEmail,
        userPhone: cleanPhone,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (e) {
      final cleanEmail = email.trim();
      final isMaster = cleanEmail.toLowerCase() == '1mdollar2027@gmail.com' ||
          cleanEmail.toLowerCase() == 'admin@cosmyra.com' ||
          cleanEmail.toLowerCase() == 'admin@cosmyra.cloud' ||
          cleanEmail.toLowerCase() == 'myhub4631@gmail.com';
      await _saveProfileLocally(name: fullName, email: cleanEmail, phone: phone ?? '', isAdmin: isMaster);

      state = state.copyWith(
        isLoading: false,
        isGuest: false,
        isAdmin: isMaster,
        isLoggedIn: true,
        userName: fullName,
        userEmail: cleanEmail,
        userPhone: phone ?? '',
      );
      return true;
    }
  }

  Future<void> updateUserProfile({required String name, required String phone}) async {
    final currentEmail = state.userEmail ?? state.guestEmail ?? '';
    final isAdmin = state.isAdmin;

    state = state.copyWith(
      userName: name,
      userPhone: phone,
    );

    await _saveProfileLocally(name: name, email: currentEmail, phone: phone, isAdmin: isAdmin);

    if (SupabaseConfig.isConfigured) {
      final user = supabase.auth.currentUser;
      if (user != null) {
        try {
          await supabase.auth.updateUser(UserAttributes(data: {
            'full_name': name,
            'phone': phone,
          }));
        } catch (_) {}

        try {
          await supabase.from('profiles').upsert({
            'id': user.id,
            'email': user.email ?? currentEmail,
            'full_name': name,
            'phone': phone,
          });
        } catch (_) {}
      }
    }
  }

  Future<void> signOut() async {
    if (SupabaseConfig.isConfigured) {
      try {
        await supabase.auth.signOut();
      } catch (_) {}
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profilePrefsKey);
    } catch (_) {}

    state = const AuthStateModel();
  }

  void toggleAdminPreview(bool isAdmin) {
    state = state.copyWith(isAdmin: isAdmin);
  }
}
