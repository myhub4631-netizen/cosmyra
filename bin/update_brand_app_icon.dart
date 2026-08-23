import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://tkwxkmmxweqrfdttkjfd.supabase.co',
    'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON',
  );

  print('Syncing brand app icon logo_url in Supabase DB...');

  const logoUrl = 'https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/catalog_baseline/shampoo.jpg';

  try {
    final response = await supabase
        .from('brands')
        .update({'logo_url': logoUrl})
        .eq('id', '6242b75a-f2b3-4895-8927-95ce0e24fa3c')
        .select();
    print('SUCCESS updating brand logo_url: $response');
  } catch (e) {
    print('ERROR updating brand logo_url: $e');
  }
}
