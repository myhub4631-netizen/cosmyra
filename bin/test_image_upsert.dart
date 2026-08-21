import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://tkwxkmmxweqrfdttkjfd.supabase.co',
    'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON',
  );

  final String prodId = '00001724-2150-4000-a000-000000000001';
  final String imageUrl = 'https://tkwxkmmxweqrfdttkjfd.supabase.co/storage/v1/object/public/product-images/test/shampoo.jpg';

  final imgData = {
    'product_id': prodId,
    'image_url': imageUrl,
    'alt_text': 'Test image',
    'display_order': 0,
    'is_primary': true,
  };

  print('Testing upserting imgData to Supabase product_images table...');
  try {
    final response = await supabase.from('product_images').upsert(imgData).select();
    print('SUCCESS! Response: $response');
  } catch (e) {
    print('ERROR upserting product_images: $e');
  }
}
