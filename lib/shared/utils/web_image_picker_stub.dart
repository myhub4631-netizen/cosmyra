import 'dart:convert';
import 'package:file_picker/file_picker.dart';

Future<String?> pickImageAsBase64() async {
  try {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final bytes = result.files.first.bytes;
      if (bytes != null) {
        return 'data:image/png;base64,${base64Encode(bytes)}';
      }
    }
  } catch (_) {}
  return null;
}
