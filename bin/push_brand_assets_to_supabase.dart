import 'dart:io';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://tkwxkmmxweqrfdttkjfd.supabase.co',
    'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON',
  );

  print('1. Uploading brand assets to Supabase Storage...');
  final logoFile = File('assets/images/cosmyra_full_logo.png');
  final appIconFile = File('assets/images/app_icon.png');

  if (!logoFile.existsSync() || !appIconFile.existsSync()) {
    print('Error: Asset files not found locally.');
    exit(1);
  }

  final logoBytes = await logoFile.readAsBytes();
  final appIconBytes = await appIconFile.readAsBytes();

  const logoStoragePath = 'brand/cosmyra_full_logo.png';
  const iconStoragePath = 'brand/cosmyra_app_icon.png';

  try {
    await supabase.storage.from('product-images').uploadBinary(
      logoStoragePath,
      logoBytes,
      fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
    );
    print('Uploaded logo to storage path: $logoStoragePath');

    await supabase.storage.from('product-images').uploadBinary(
      iconStoragePath,
      appIconBytes,
      fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
    );
    print('Uploaded icon to storage path: $iconStoragePath');

    final logoPublicUrl = supabase.storage.from('product-images').getPublicUrl(logoStoragePath);
    print('Public Logo URL: $logoPublicUrl');

    print('2. Updating Supabase DB brands table...');
    final response = await supabase
        .from('brands')
        .update({'logo_url': logoPublicUrl})
        .eq('id', '6242b75a-f2b3-4895-8927-95ce0e24fa3c')
        .select();

    print('DB Update Result: $response');
    print('SUCCESSFULLY pushed brand logo and app icon to Supabase!');
  } catch (e) {
    print('Error during Supabase push: $e');
  }
}
