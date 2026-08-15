import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/routes.dart';
import 'config/supabase_config.dart';
import 'config/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase Flutter SDK
  await SupabaseConfig.init();

  runApp(
    const ProviderScope(
      child: CosmyraApp(),
    ),
  );
}

class CosmyraApp extends StatelessWidget {
  const CosmyraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cosmyra • Vaidyam Botanicals',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
