import 'package:flutter/services.dart';

/// Saves the currently loaded bill page as a paginated A4 PDF.
///
/// Implemented in MainActivity.kt (channel "dev.asanbill/pdf", method
/// "printUrlToPdf"): an offscreen WebView renders the page and draws it
/// slice-by-slice into a PdfDocument — no print dialog, no extra
/// dependencies, public Android APIs only. The PDF is written straight into
/// the app's private vault directory; the absolute path is returned.
class PdfService {
  static const _channel = MethodChannel('dev.asanbill/pdf');

  /// Prints [url] to [fileName].pdf and returns the absolute file path.
  /// Throws a [PlatformException] on failure.
  static Future<String> printUrlToPdf({
    required String url,
    required String fileName,
  }) async {
    final name = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
    final path = await _channel.invokeMethod<String>(
      'printUrlToPdf',
      {'url': url, 'fileName': name},
    );
    if (path == null || path.isEmpty) {
      throw PlatformException(
        code: 'PDF_EMPTY_PATH',
        message: 'The native print returned no file path.',
      );
    }
    return path;
  }
}
