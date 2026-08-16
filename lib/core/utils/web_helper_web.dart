import 'dart:html' as html;

void updateDomFavicon(String url) {
  try {
    final String targetUrl = url.isNotEmpty ? url : 'favicon.png?v=${DateTime.now().millisecondsSinceEpoch}';
    final links = html.document.querySelectorAll("link[rel*='icon']");
    for (final link in links) {
      link.setAttribute('href', targetUrl);
    }
    final element = html.document.getElementById('app-favicon');
    if (element != null) {
      element.setAttribute('href', targetUrl);
    }
  } catch (_) {}
}

void downloadTextFile(String filename, String content) {
  try {
    final blob = html.Blob([content], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  } catch (_) {}
}
