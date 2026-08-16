import 'dart:async';
import 'dart:html' as html;

Future<String?> pickImageAsBase64() async {
  final completer = Completer<String?>();
  try {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((e) {
          final String? result = reader.result as String?;
          if (!completer.isCompleted) {
            completer.complete(result);
          }
        });
      } else {
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      }
    });

    // Timeout fallback if user cancels
    Future.delayed(const Duration(minutes: 2), () {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });
  } catch (e) {
    if (!completer.isCompleted) {
      completer.complete(null);
    }
  }
  return completer.future;
}
