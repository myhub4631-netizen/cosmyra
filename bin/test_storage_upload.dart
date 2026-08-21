import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase/supabase.dart';

void main() async {
  final supabase = SupabaseClient(
    'https://tkwxkmmxweqrfdttkjfd.supabase.co',
    'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON',
  );

  final String sampleBase64 = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

  try {
    final mimeMatch = RegExp(r'data:image/([a-zA-Z0-9+\-]+);base64,').firstMatch(sampleBase64);
    final extension = mimeMatch?.group(1) ?? 'png';
    final base64Str = sampleBase64.split(',').last.replaceAll(RegExp(r'[\r\n\s]+'), '');
    final Uint8List bytes = base64Decode(base64Str);

    final filePath = 'test_dart/img_${DateTime.now().millisecondsSinceEpoch}.$extension';
    print('Uploading bytes to Supabase storage path: $filePath');

    await supabase.storage.from('product-images').uploadBinary(
      filePath,
      bytes,
      fileOptions: FileOptions(contentType: 'image/$extension', upsert: true),
    );

    final publicUrl = supabase.storage.from('product-images').getPublicUrl(filePath);
    print('SUCCESS! Public URL: $publicUrl');
  } catch (e) {
    print('ERROR uploading: $e');
  }
}
