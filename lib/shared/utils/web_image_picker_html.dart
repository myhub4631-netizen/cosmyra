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
          if (result == null || result.isEmpty) {
            if (!completer.isCompleted) completer.complete(null);
            return;
          }

          // Use HTML Canvas to compress & downscale high-res images to ~1200px max dimension
          final img = html.ImageElement();
          img.src = result;
          img.onLoad.listen((_) {
            try {
              int width = img.width ?? 800;
              int height = img.height ?? 800;
              const int maxDim = 1200;

              if (width > maxDim || height > maxDim) {
                if (width > height) {
                  height = (height * maxDim / width).round();
                  width = maxDim;
                } else {
                  width = (width * maxDim / height).round();
                  height = maxDim;
                }
              }

              final canvas = html.CanvasElement(width: width, height: height);
              final ctx = canvas.context2D;
              ctx.drawImageScaled(img, 0, 0, width, height);

              final compressedDataUrl = canvas.toDataUrl('image/jpeg', 0.85);
              if (!completer.isCompleted) {
                completer.complete(compressedDataUrl);
              }
            } catch (_) {
              if (!completer.isCompleted) completer.complete(result);
            }
          });
          img.onError.listen((_) {
            if (!completer.isCompleted) completer.complete(result);
          });
        });
      } else {
        if (!completer.isCompleted) completer.complete(null);
      }
    });

    Future.delayed(const Duration(minutes: 2), () {
      if (!completer.isCompleted) completer.complete(null);
    });
  } catch (e) {
    if (!completer.isCompleted) completer.complete(null);
  }
  return completer.future;
}
