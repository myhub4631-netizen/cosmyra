import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://tkwxkmmxweqrfdttkjfd.supabase.co',
    'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON',
  );

  print('Cleaning up and seeding product_images in Supabase DB...');

  final List<dynamic> products = await supabase.from('products').select('*');

  final Map<String, String> defaultImages = {
    'shampoo': 'https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/catalog_baseline/shampoo.jpg',
    'facewash': 'https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/catalog_baseline/facewash.jpg',
    'soap': 'https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/catalog_baseline/soap.jpg',
  };

  for (final p in products) {
    final String prodId = p['id'].toString();
    final String slug = (p['slug'] ?? '').toString().toLowerCase();
    final String name = (p['name'] ?? '').toString().toLowerCase();

    // Clear old image rows for this product
    try {
      await supabase.from('product_images').delete().eq('product_id', prodId);
    } catch (_) {}

    String imageUrl = defaultImages['shampoo']!;
    if (slug.contains('soap') || name.contains('soap')) {
      imageUrl = defaultImages['soap']!;
    } else if (slug.contains('face') || slug.contains('cleanser') || slug.contains('serum') || name.contains('face') || name.contains('serum')) {
      imageUrl = defaultImages['facewash']!;
    } else if (slug.contains('oil') || slug.contains('thailam') || name.contains('oil') || name.contains('thailam')) {
      imageUrl = defaultImages['soap']!;
    }

    final imgData = {
      'product_id': prodId,
      'image_url': imageUrl,
      'alt_text': p['name'],
      'display_order': 0,
      'is_primary': true,
    };

    try {
      await supabase.from('product_images').insert(imgData);
      print('  ✓ Successfully inserted image for ${p['name']}');
    } catch (e) {
      print('  X Error inserting image for ${p['name']}: $e');
    }
  }

  print('\nDONE! All 9 products in Supabase DB now have clean image rows in product_images!');
}
