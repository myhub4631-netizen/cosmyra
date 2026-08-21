import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://tkwxkmmxweqrfdttkjfd.supabase.co',
    'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON',
  );

  print('Cleaning up duplicate rows in Supabase DB...');
  final List<dynamic> products = await supabase.from('products').select('*');
  
  final Map<String, List<Map<String, dynamic>>> slugGroups = {};
  for (final p in products) {
    final String slug = (p['slug'] ?? '').toString().trim().toLowerCase();
    if (slug.isNotEmpty) {
      slugGroups.putIfAbsent(slug, () => []).add(p as Map<String, dynamic>);
    }
  }

  for (final entry in slugGroups.entries) {
    final list = entry.value;
    if (list.length > 1) {
      print('Found ${list.length} rows for slug "${entry.key}". Deduplicating...');
      list.sort((a, b) => (b['created_at'] ?? '').toString().compareTo((a['created_at'] ?? '').toString()));
      final keepId = list.first['id'];
      for (int i = 1; i < list.length; i++) {
        final deleteId = list[i]['id'];
        print('  Deleting duplicate row ID: $deleteId');
        try {
          await supabase.from('product_images').delete().eq('product_id', deleteId);
          await supabase.from('product_variants').delete().eq('product_id', deleteId);
          await supabase.from('products').delete().eq('id', deleteId);
        } catch (e) {
          print('  Error deleting row $deleteId: $e');
        }
      }
    }
  }

  print('Deduplication completed successfully!');
}
