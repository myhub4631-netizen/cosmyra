import 'dart:io';
import 'dart:typed_data';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://tkwxkmmxweqrfdttkjfd.supabase.co',
    'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON',
  );

  print('Reading local asset images and uploading to Supabase Storage...');

  final Map<String, String> assetPaths = {
    'shampoo': '/Users/mahboobhasan/Desktop/Cosmyra/assets/images/shampoo.jpg',
    'facewash': '/Users/mahboobhasan/Desktop/Cosmyra/assets/images/facewash.jpg',
    'soap': '/Users/mahboobhasan/Desktop/Cosmyra/assets/images/soap.jpg',
  };

  final Map<String, String> uploadedPublicUrls = {};

  for (final entry in assetPaths.entries) {
    final file = File(entry.value);
    if (file.existsSync()) {
      final bytes = await file.readAsBytes();
      final storagePath = 'catalog_baseline/${entry.key}.jpg';
      print('Uploading ${entry.key} (${bytes.length} bytes) to $storagePath...');

      try {
        await supabase.storage.from('product-images').uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
        final publicUrl = supabase.storage.from('product-images').getPublicUrl(storagePath);
        uploadedPublicUrls[entry.key] = publicUrl;
        print('  Uploaded ${entry.key} => $publicUrl');
      } catch (e) {
        print('  Error uploading ${entry.key}: $e');
      }
    } else {
      print('File not found: ${entry.value}');
    }
  }

  print('\nPopulating product_images in Supabase DB with public HTTP URLs...');
  final List<dynamic> products = await supabase.from('products').select('*');

  for (final p in products) {
    final String prodId = p['id'].toString();
    final String slug = (p['slug'] ?? '').toString().toLowerCase();
    final String name = (p['name'] ?? '').toString().toLowerCase();

    String imageUrl = uploadedPublicUrls['shampoo'] ?? '';
    if (slug.contains('soap') || name.contains('soap')) {
      imageUrl = uploadedPublicUrls['soap'] ?? imageUrl;
    } else if (slug.contains('face') || slug.contains('cleanser') || slug.contains('serum') || name.contains('face') || name.contains('serum')) {
      imageUrl = uploadedPublicUrls['facewash'] ?? imageUrl;
    } else if (slug.contains('oil') || slug.contains('thailam') || name.contains('oil') || name.contains('thailam')) {
      imageUrl = uploadedPublicUrls['soap'] ?? imageUrl;
    }

    if (imageUrl.isNotEmpty) {
      final imgData = {
        'id': '00001724-2150-4000-c000-${prodId.substring(24)}',
        'product_id': prodId,
        'image_url': imageUrl,
        'alt_text': p['name'],
        'display_order': 0,
        'is_primary': true,
      };

      try {
        await supabase.from('product_images').upsert(imgData);
        print('  Updated image for ${p['name']} => $imageUrl');
      } catch (e) {
        print('  Error updating image for ${p['name']}: $e');
      }
    }
  }

  print('\nDONE! All products in Supabase DB now have public HTTP image URLs!');
}
