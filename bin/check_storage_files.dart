import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://tkwxkmmxweqrfdttkjfd.supabase.co',
    'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON',
  );

  print('Listing files in product-images bucket...');
  try {
    final files = await supabase.storage.from('product-images').list();
    for (final f in files) {
      print('  - ${f.name} (isDir: ${f.id == null})');
      if (f.id == null) {
        final subFiles = await supabase.storage.from('product-images').list(path: f.name);
        for (final sf in subFiles) {
          print('      └─ ${f.name}/${sf.name}');
        }
      }
    }
  } catch (e) {
    print('Error listing files: $e');
  }
}
