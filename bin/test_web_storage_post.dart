import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

void main() async {
  const supabaseUrl = 'https://tkwxkmmxweqrfdttkjfd.supabase.co';
  const supabaseAnonKey = 'sb_publishable_8qq6FNGeCch_xx3kWM9wcw_jmoleoON';

  final String sampleBase64 = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

  try {
    final mimeMatch = RegExp(r'data:image/([a-zA-Z0-9+\-]+);base64,').firstMatch(sampleBase64);
    final extension = mimeMatch?.group(1) ?? 'png';
    final base64Str = sampleBase64.split(',').last.replaceAll(RegExp(r'[\r\n\s]+'), '');
    final Uint8List bytes = base64Decode(base64Str);

    final filePath = 'direct_post/img_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final uploadUrl = Uri.parse('$supabaseUrl/storage/v1/object/product-images/$filePath');

    print('Uploading via HTTP POST to: $uploadUrl');

    final response = await http.post(
      uploadUrl,
      headers: {
        'apikey': supabaseAnonKey,
        'Authorization': 'Bearer $supabaseAnonKey',
        'Content-Type': 'image/$extension',
        'x-upsert': 'true',
      },
      body: bytes,
    );

    print('Response statusCode: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final publicUrl = '$supabaseUrl/storage/v1/object/public/product-images/$filePath';
      print('SUCCESS! Public URL: $publicUrl');
    } else {
      print('FAILED to upload image');
    }
  } catch (e) {
    print('Error during HTTP upload: $e');
  }
}
