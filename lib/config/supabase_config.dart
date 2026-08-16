import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase Configuration and Initialization Helper
class SupabaseConfig {
  /// Replace these placeholders with your actual Supabase Project URL and Anon API Key / Publishable Key.
  /// You can find these in your Supabase Dashboard under:
  /// Project Settings -> API
  static const String url = 'https://tkwxkmmxweqrfdttkjfd.supabase.co';
  static const String anonKey = 'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON';

  /// Initialize Supabase Flutter SDK
  static Future<void> init() async {
    // Avoid initializing if default placeholder values or dummy URLs are present
    if (!isConfigured) {
      return;
    }

    try {
      await Supabase.initialize(
        url: url,
        publishableKey: anonKey,
      );
    } catch (_) {}
  }

  /// Global shortcut getter for Supabase Client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Check if Supabase has been initialized with valid credentials
  static bool get isConfigured =>
      url.isNotEmpty &&
      !url.contains('YOUR_SUPABASE_PROJECT_ID') &&
      anonKey.isNotEmpty &&
      anonKey != 'YOUR_SUPABASE_ANON_KEY';
}

/// Global convenience accessor for the Supabase client
SupabaseClient get supabase => Supabase.instance.client;
